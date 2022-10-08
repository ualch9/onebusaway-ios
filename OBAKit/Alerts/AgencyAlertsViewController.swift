//
//  AgencyAlertsViewController.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import SwiftUI
import OBAKitCore
import SafariServices

/// Displays `AgencyAlert` objects loaded from a Protobuf feed.
class AgencyAlertsViewController: UICollectionViewController, AgencyAlertsDelegate, AgencyAlertListViewConverters, AppContext {

    struct ViewModel: Hashable {
        var id: String
        var title: String
        var subtitle: String?
        var isHeader: Bool

        init(headerWithTitle title: String) {
            self.id = "\(title)"
            self.title = title
            self.subtitle = nil
            self.isHeader = true
        }

        init(_ alert: AgencyAlert) {
            self.id = alert.id
            self.title = alert.title(forLocale: .current) ?? ""
            self.subtitle = alert.body(forLocale: .current)
            self.isHeader = false
        }

        var contentConfiguration: UIListContentConfiguration {
            var config: UIListContentConfiguration = isHeader ? .plainHeader() : .cell()
            config.text = title
            config.secondaryText = subtitle
            config.secondaryTextProperties.numberOfLines = 3

            if isHeader {
                config.textProperties.font = .preferredFont(forTextStyle: .headline)
            }

            return config
        }
    }

    // MARK: - Stores
    public let application: Application
    private let alertsStore: AgencyAlertsStore

    /// A map of `UIViewController`s responsible for each `AgencyAlert`'s context menu preview.
    fileprivate let previewingViewControllers: NSMapTable<NSString, UIViewController> = .strongToWeakObjects()

    // MARK: - Collection view
    fileprivate var dataSource: UICollectionViewDiffableDataSource<String, ViewModel>!
    fileprivate var headerCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ViewModel>!
    fileprivate var alertCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ViewModel>!

    fileprivate let refreshControl = UIRefreshControl()

    // MARK: - Init
    public init(application: Application) {
        self.application = application
        self.alertsStore = application.alertsStore

        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .firstItemInSection
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: config))

        self.alertsStore.addDelegate(self)

        title = OBALoc("agency_alerts_controller.title", value: "Alerts", comment: "The title of the Agency Alerts controller.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController
    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(reloadServerData), for: .valueChanged)

        self.view.backgroundColor = ThemeColors.shared.systemBackground

        self.headerCellRegistration = UICollectionView.CellRegistration(handler: cellForHeader)
        self.alertCellRegistration = UICollectionView.CellRegistration(handler: cellForAlert)
        self.dataSource = UICollectionViewDiffableDataSource<String, ViewModel>(collectionView: self.collectionView, cellProvider: self.cellProvider)
        self.dataSource.reorderingHandlers.canReorderItem = { itemIdentifier in
            return self.isEditing && itemIdentifier.isHeader
        }

        self.collectionView.refreshControl = refreshControl
        self.collectionView.dataSource = self.dataSource

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        reloadServerData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        let sections = self.dataSource.snapshot().sectionIdentifiers

        for section in sections {
            var sectionSnapshot = self.dataSource.snapshot(for: section)
            if editing {
                sectionSnapshot.collapse(sectionSnapshot.rootItems)
                self.dataSource.apply(sectionSnapshot, to: section, animatingDifferences: true)
            } else {
                sectionSnapshot.expand(sectionSnapshot.rootItems)
                self.dataSource.apply(sectionSnapshot, to: section, animatingDifferences: true)
            }
        }
    }

    // MARK: - Actions
    @objc func didSelectFilterButton(_ sender: Any?) {
        let vc = AgencyAlertsFilterViewController(application: application, allAgencies: self.dataSource.snapshot().sectionIdentifiers)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Collection view providers

    fileprivate func cellForHeader(_ cell: UICollectionViewListCell, _ indexPath: IndexPath, _ item: ViewModel) {
        var config = item.contentConfiguration
        config.textProperties.transform = .uppercase
        cell.contentConfiguration = config
        cell.accessories = [.reorder(displayed: .whenEditing)]
    }

    fileprivate func cellForAlert(_ cell: UICollectionViewListCell, _ indexPath: IndexPath, _ item: ViewModel) {
        cell.contentConfiguration = item.contentConfiguration
        cell.accessories = [.disclosureIndicator()]
    }

    fileprivate func cellProvider(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ViewModel) -> UICollectionViewCell? {
        if item.isHeader {
            return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
        } else {
            return collectionView.dequeueConfiguredReusableCell(using: alertCellRegistration, for: indexPath, item: item)
        }
    }

    // MARK: - Agency Alerts Delegate

    func agencyAlertsUpdated() {
        self.alertsDidUpdate()
        refreshControl.endRefreshing()
    }

    var localSnapshot: [String: [AgencyAlert]] = [:]

    func alertsDidUpdate() {
        let alerts = alertsStore.agencyAlerts

        localSnapshot.removeAll(keepingCapacity: true)
        for alert in alerts {
            let agencyName = alert.agency?.agency.name ?? ""

            var value: [AgencyAlert] = localSnapshot[agencyName] ?? []
            value.append(alert)
            localSnapshot.updateValue(value, forKey: agencyName)
        }

        var snapshot = NSDiffableDataSourceSnapshot<String, ViewModel>()

        snapshot.appendSections(Array(localSnapshot.keys).sorted())

        for (key, value) in localSnapshot {
            let header = ViewModel(headerWithTitle: key)
            let items = value.map(ViewModel.init)

            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ViewModel>()
            sectionSnapshot.append([header])
            sectionSnapshot.append(items, to: header)
            sectionSnapshot.expand([header])
            dataSource.apply(sectionSnapshot, to: key)
        }
    }

    // MARK: - Data Loading

    @objc private func reloadServerData() {
        alertsStore.checkForUpdates()
        refreshControl.beginRefreshing()
    }

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        guard let indexPath = indexPaths.first else {
//            // If there is no index path, then the section header is calling this method.
//            return nil
//        }
//
//        guard let alert = self.dataSource.itemIdentifier(for: indexPath) else {
//            return nil
//        }
//
//        return UIContextMenuConfiguration(identifier: menuIdentifier(for: alert)) { [self] in
//            return previewViewController(for: alert)
//        } actionProvider: { [self] _ in
//            return menu(for: alert)
//        }
        return nil
    }

    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let previewingVC = previewingViewControllers.object(forKey: configuration.identifier as? NSString) else {
            return
        }

        animator.addAnimations {
            self.application.viewRouter.navigate(to: previewingVC, from: self)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let alert = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }

//        self.application.viewRouter.navigateTo(alert: alert, from: self)
    }

    // MARK: - Context Menu
    fileprivate func menuIdentifier(for alert: AgencyAlert) -> NSString {
        return alert.id as NSString
    }

    fileprivate func previewViewController(for alert: AgencyAlert) -> UIViewController? {
        let viewController = self.application.viewRouter.viewController(for: alert)
        self.previewingViewControllers.setObject(viewController, forKey: menuIdentifier(for: alert))
        return viewController
    }

    fileprivate func menu(for alert: AgencyAlert) -> UIMenu? {
        return UIMenu(children: [shareAlertAction(alert)])
    }

    // MARK: - Menu actions
    /// Returns a UIAction that presents a `UIActivityViewController` for sharing the URL
    /// (or title and body, if no URL) of the provided alert.
    func shareAlertAction(_ alert: AgencyAlert) -> UIAction {
        let activityItems: [Any]
        if let url = alert.url(forLocale: .current) {
            activityItems = [url]
        } else {
            activityItems = [alert.title, alert.body]
        }

        return UIAction(title: Strings.share, image: Icons.share) { [weak self] _ in
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            self?.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: - List data

    // FIXME: empty data!
//    func emptyData(for listView: OBAListView) -> OBAListView.EmptyData? {
//        let regionName = application.currentRegion?.name
//        return .standard(.init(title: Strings.emptyAlertTitle, body: regionName))
//    }
}
