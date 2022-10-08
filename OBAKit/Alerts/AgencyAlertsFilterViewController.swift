//
//  AgencyAlertsFilterViewController.swift
//  OBAKit
//
//  Created by Alan Chu on 10/6/22.
//

import UIKit
import OBAKitCore

public protocol AgencyAlertsFilterDelegate: AnyObject {
    func selectedAgenciesDidChange(_ filterViewController: AgencyAlertsFilterViewController)
}

public class AgencyAlertsFilterViewController: UICollectionViewController, AppContext {
    enum Section {
        case agencies
    }

    public fileprivate(set) var selectedAgencies: [String] = []
    public fileprivate(set) var allAgencies: [String]

    public weak var filterDelegate: AgencyAlertsFilterDelegate?

    var application: Application
//    fileprivate var dataSource: UICollectionViewDiffableDataSource<Section, String>!

    fileprivate var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, String>!

    public init(application: Application, allAgencies: [String], appearance: UICollectionLayoutListConfiguration.Appearance = .grouped) {
        self.application = application
        self.allAgencies = allAgencies.sorted()

        var config = UICollectionLayoutListConfiguration(appearance: appearance)
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: config))

//        self.dataSource = .init(collectionView: self.collectionView, cellProvider: cellProvider)
        self.cellRegistration = UICollectionView.CellRegistration(handler: cellForAgency)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            fatalError()
        }

        return allAgencies.count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let agency = allAgencies[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: agency)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.isEditing = true
    }

    fileprivate func cellForAgency(_ cell: UICollectionViewListCell, indexPath: IndexPath, agency: String) {
        var content = cell.defaultContentConfiguration()
        content.text = agency

        cell.contentConfiguration = content
        cell.accessories = [.multiselect(displayed: .whenEditing)]
    }

    fileprivate func cellProvider(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ agency: String) -> UICollectionViewCell? {
        return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: agency)
    }
}
