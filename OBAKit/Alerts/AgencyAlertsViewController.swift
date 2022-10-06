//
//  AgencyAlertsViewController.swift
//  OBAKit
//
//  Copyright © Open Transit Software Foundation
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit
import OBAKitCore
import SafariServices

/// Displays `AgencyAlert` objects loaded from a Protobuf feed.
class AgencyAlertsViewController: UICollectionViewController, AgencyAlertsDelegate, AgencyAlertListViewConverters, AppContext {

    // MARK: - Stores
    public let application: Application
    private let alertsStore: AgencyAlertsStore

    /// A map of `UIViewController`s responsible for each `AgencyAlert`'s context menu preview.
    fileprivate let previewingViewControllers: NSMapTable<NSString, UIViewController> = .strongToWeakObjects()

    // MARK: - Collection view
    fileprivate var dataSource: UICollectionViewDiffableDataSource<String, AgencyAlert>!
    fileprivate var sectionSupplementaryRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    fileprivate var alertCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, AgencyAlert>!

    fileprivate let refreshControl = UIRefreshControl()

    // MARK: - Init
    public init(application: Application) {
        self.application = application
        self.alertsStore = application.alertsStore

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.headerMode = .supplementary
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

        self.sectionSupplementaryRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader, handler: cellForHeader)
        self.alertCellRegistration = UICollectionView.CellRegistration(handler: cellForAlert)
        self.dataSource = UICollectionViewDiffableDataSource<String, AgencyAlert>(collectionView: self.collectionView, cellProvider: self.cellProvider)
        self.dataSource.supplementaryViewProvider = self.supplementaryViewProvider

        self.collectionView.refreshControl = refreshControl
        self.collectionView.dataSource = self.dataSource

        reloadServerData()
    }

    // MARK: - Collection view providers

    fileprivate func supplementaryViewProvider(_ collectionView: UICollectionView, elementKind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        guard elementKind == UICollectionView.elementKindSectionHeader else {
            return nil
        }

        return collectionView.dequeueConfiguredReusableSupplementary(using: sectionSupplementaryRegistration, for: indexPath)
    }

    fileprivate func cellForHeader(_ cell: UICollectionViewListCell, kind: String, indexPath: IndexPath) {
        guard kind == UICollectionView.elementKindSectionHeader else { return }

        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

        var content = UIListContentConfiguration.plainHeader()
        content.text = section
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.textProperties.transform = .uppercase

        cell.contentConfiguration = content
    }

    fileprivate func cellForAlert(_ cell: UICollectionViewListCell, indexPath: IndexPath, agencyAlert: AgencyAlert) {
        var content = cell.defaultContentConfiguration()
        content.text = agencyAlert.title(forLocale: .current)
        content.secondaryText = agencyAlert.body(forLocale: .current)
        content.secondaryTextProperties.numberOfLines = 3

        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    func cellProvider(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ agencyAlert: AgencyAlert) -> UICollectionViewCell? {
        return collectionView.dequeueConfiguredReusableCell(using: self.alertCellRegistration, for: indexPath, item: agencyAlert)
    }

    // MARK: - Agency Alerts Delegate

    func agencyAlertsUpdated() {
        self.alertsDidUpdate()
        refreshControl.endRefreshing()
        navigationItem.rightBarButtonItem = nil
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

        var snapshot = NSDiffableDataSourceSnapshot<String, AgencyAlert>()
        snapshot.appendSections(Array(localSnapshot.keys))

        for (key, value) in localSnapshot {
            snapshot.appendItems(value, toSection: key)
        }

        self.dataSource.apply(snapshot)
    }

    // MARK: - Data Loading

    @objc private func reloadServerData() {
        alertsStore.checkForUpdates()
        refreshControl.beginRefreshing()
    }

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else {
            // If there is no index path, then the section header is calling this method.
            return nil
        }

        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let alert = self.dataSource.snapshot().itemIdentifiers(inSection: section)[indexPath.row]

        return UIContextMenuConfiguration(identifier: menuIdentifier(for: alert)) { [self] in
            return previewViewController(for: alert)
        } actionProvider: { [self] _ in
            return menu(for: alert)
        }
    }

    fileprivate func menuIdentifier(for alert: AgencyAlert) -> NSString {
        return alert.id as NSString
    }

    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let previewingVC = previewingViewControllers.object(forKey: configuration.identifier as? NSString) else {
            return
        }

        if previewingVC is TransitAlertDetailViewController {
            animator.addAnimations {
                self.application.viewRouter.navigate(to: previewingVC, from: self)
            }
        } else {
            animator.addAnimations {
                self.application.viewRouter.present(previewingVC, from: self, isModal: true)
            }
        }
    }

    // MARK: - Context Menu

    fileprivate func previewViewController(for alert: AgencyAlert) -> UIViewController? {
        let viewController: UIViewController
        if let url = alert.url(forLocale: .current) {
            viewController = SFSafariViewController(url: url)
        } else {
            viewController = TransitAlertDetailViewController(alert)
        }

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
