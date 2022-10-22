//
//  MapPanelNearbyView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/15/22.
//

import SwiftUI

struct MapPanelStopView: View {
    @State var stop: StopViewModel

    var body: some View {
        HStack {
            Image(uiImage: Icons.transportIcon(from: stop.routeType))
                .resizable()
                .frame(maxWidth: 18, maxHeight: 18)
                .foregroundColor(Color.primary)
            VStack(alignment: .leading) {
                Text(stop.name)
                    .font(.headline)
                if let subtitle = stop.subtitle {
                    Text(subtitle)
                        .font(.caption)
                }
            }

            Spacer()

            Image(systemName: "chevron.forward")
                .foregroundColor(.secondary)
        }
    }
}

extension StopViewModel {
    var panelViewIdentifier: MapPanelViewIdentifier {
        return .stop(id)
    }
}

struct MapPanelStopView_Preview: PreviewProvider {
    static var previews: some View {
        MapPanelStopView(stop: .samples[0])
    }
}
