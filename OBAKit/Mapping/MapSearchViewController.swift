//
//  MapSearchViewController.swift
//  OBAKit
//
//  Created by Alan Chu on 12/25/22.
//

import SwiftUI
import Foundation
import OBAKitCore

class MapSearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    let coordinator = MapPanelSearchProvider(nil)
    private var standardView: UIHostingController<Text>!
    private var searchView: UIHostingController<MapPanelSearchView>!
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.standardView = UIHostingController(rootView: Text("Standard view"))
        self.searchView = UIHostingController(rootView: MapPanelSearchView(provider: coordinator))

        self.searchController = UISearchController(searchResultsController: searchView)
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.showsSearchResultsController = true
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true

        definesPresentationContext = true

        addChild(self.standardView)
        self.standardView.view.frame = self.view.frame
        self.view.addSubview(standardView.view)
        self.standardView.didMove(toParent: self)
    }

    // MARK: - UISearchBarDelegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coordinator.searchQuery = searchText
    }
}

struct MapSearchViewControllerPreviews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            UINavigationController(rootViewController: MapSearchViewController())
        }
    }
}
