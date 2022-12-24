//
//  MapPanelSearchView.swift
//  OBAKit
//
//  Created by Alan Chu on 12/10/22.
//

import SwiftUI

struct MapPanelSearchView: View {
    var body: some View {
        emptyStateView
    }

    var emptyStateView: some View {
        VStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
            Text("Search")
                .font(.title)

            Spacer()
            
            Text("Type in an address, route name, stop number, or vehicle here to search")
                .font(.headline)
        }

        .multilineTextAlignment(.center)
        .padding()
    }
}

struct MapPanelSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapPanelSearchView()
    }
}
