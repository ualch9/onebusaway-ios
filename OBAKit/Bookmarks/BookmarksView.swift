//
//  BookmarksView.swift
//  OBAKit
//
//  Created by Alan Chu on 10/6/21.
//

import SwiftUI
import OBAKitCore

struct BookmarksView: View {
    @Environment(\.coreApplication) var application
    @ObservedObject var bookmarksDAO = BookmarksDataModel()
    @State var isEditingSections: Bool = false

    public weak var delegate: BookmarksViewDelegate?

    init(delegate: BookmarksViewDelegate? = nil) {
        self.delegate = delegate
    }

    var body: some View {
        List(bookmarksDAO.groups) { group in
            if isEditingSections {
                editingBookmarks(for: group)
            } else {
                bookmarkSection(for: group)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(OBALoc("bookmarks_controller.title", value: "Bookmarks", comment: "Title of the Bookmarks tab"))
        .listStyle(.plain)
        .toolbar {
            Button {
                bookmarksDAO.reloadData()
            } label: {
                Image(systemName: "arrow.clockwise")
            }

            Button("Toggle edit") {
                isEditingSections.toggle()
            }
        }
        .onAppear {
            bookmarksDAO.reloadData()
        }
    }

    func bookmarkSection(for group: BookmarkGroupViewModel) -> some View {
        Section {
            ForEach(group.bookmarks) { bookmark in
                if case let BookmarkViewModel.stop(stop) = bookmark {
                    StopBookmarkView(viewModel: stop)
                        .onTapGesture {
                            self.delegate?.routeToStop(stopID: stop.id)
                        }
                } else if case let BookmarkViewModel.trip(trip) = bookmark {
                    TripBookmarkView(viewModel: trip)
                        .onTapGesture {
                            self.delegate?.routeToStop(stopID: trip.stopID)
                        }
                }
            }
        } header: {
            Text(group.name)
                .textCase(.uppercase)
                .font(.headline)
                .padding([.top, .bottom], 4)
        }
    }

    func editingBookmarks(for group: BookmarkGroupViewModel) -> some View {
        Text(group.name)
            + Text(" (")
            + Text("\(group.bookmarks.count)")
            + Text(")")
    }

}

//struct BookmarksView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            BookmarksView(viewModel: BookmarkGroupViewModel.previewGroup)
//        }
//    }
//}
