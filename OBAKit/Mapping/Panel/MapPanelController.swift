//
//  MapPanelController.swift
//  OBAKit
//
//  Created by Alan Chu on 12/25/22.
//

import SwiftUI
import Foundation
import OBAKitCore

class MapPanelController: VisualEffectViewController, UISearchControllerDelegate, UISearchBarDelegate {

    private let standardProvider = OBAMapPanelProvider()
    private var standardView: UIHostingController<MapPanelStandardView>!

    private let searchProvider = MapPanelSearchProvider(nil)
    private var searchView: UIHostingController<MapPanelSearchView>!

    private var searchBar: UISearchBar!
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        func hostingControllerForPanel<Content: View>(_ view: Content) -> UIHostingController<Content> {
            let controller = UIHostingController(rootView: view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false

            // Hides the background because the panel has a fancy VisualEffect view
            controller.view.isOpaque = false
            controller.view.backgroundColor = .clear
            return controller
        }

        self.standardView = hostingControllerForPanel(MapPanelStandardView(provider: standardProvider))
        self.searchView = hostingControllerForPanel(MapPanelSearchView(provider: searchProvider))

        self.searchBar = UISearchBar.autolayoutNew()
        self.searchBar.placeholder = "Search"
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.delegate = self

        self.view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            self.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])

        showSearchView(false)
    }

    var isShowingSearchView: Bool = false
    func showSearchView(_ show: Bool) {
        if show && isShowingSearchView {
            return
        }

        let viewToRemove: UIViewController = show ? standardView : searchView
        let viewToAdd: UIViewController = show ? searchView : standardView

        // Tear down the view to remove
        viewToRemove.view.constraints.forEach(viewToRemove.view.removeConstraint)
        viewToRemove.willMove(toParent: nil)
        self.removeChildController(viewToRemove)
        viewToRemove.view.removeFromSuperview()
        viewToRemove.didMove(toParent: nil)

        // Add the view
        self.addChild(viewToAdd)
        viewToAdd.willMove(toParent: nil)
        self.view.addSubview(viewToAdd.view)
        viewToAdd.didMove(toParent: self)

        NSLayoutConstraint.activate([
            viewToAdd.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            viewToAdd.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            viewToAdd.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            viewToAdd.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UISearchBarDelegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        showSearchView(true)
        searchProvider.searchQuery = searchText
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showSearchView(true)
        searchProvider.searchQuery = searchBar.text ?? ""
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        showSearchView(false)
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        showSearchView(false)
    }
}

struct MapSearchViewControllerPreviews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            MapPanelController()
        }
    }
}
