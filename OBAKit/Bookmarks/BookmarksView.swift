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

    @State var isDisplayingEditSheet = false

    public weak var delegate: BookmarksViewDelegate?

    init(delegate: BookmarksViewDelegate? = nil) {
        self.delegate = delegate
    }

    var body: some View {
        List(bookmarksDAO.groups) { group in
            bookmarkSection(for: group)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(OBALoc("bookmarks_controller.title", value: "Bookmarks", comment: "Title of the Bookmarks tab"))
        .listStyle(.plain)
        .sheet(isPresented: $isDisplayingEditSheet, onDismiss: {
            bookmarksDAO.reloadData()
        }, content: {
            EditBookmarksView(bookmarksDAO: bookmarksDAO)
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("Edit", action: { isDisplayingEditSheet.toggle() })
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    bookmarksDAO.reloadData()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
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
                        .onDrag { bookmark.itemProvider }
//                        .onDrag(bookmark.id as NSString, preview: Text(bookmark.name))
                } else if case let BookmarkViewModel.trip(trip) = bookmark {
                    TripBookmarkView(viewModel: trip)
                        .onTapGesture {
                            self.delegate?.routeToStop(stopID: trip.stopID)
                        }
                        .onDrag { bookmark.itemProvider }
//                        .onDrag(bookmark.id as NSString, preview: Text(bookmark.name))
                }
            }
            .onInsert(of: ["org.onebusaway.iphone.bookmark"], perform: {
                drop(bookmarkGroupID: group.id, at: $0, items: $1)
            })
        } header: {
            Text(group.name)
                .textCase(.uppercase)
                .font(.headline)
                .padding([.top, .bottom], 4)
        }
    }

    private func drop(bookmarkGroupID: UUID, at index: Int, items: [NSItemProvider]) {
        guard let item = items.first (where: { $0.hasItemConformingToTypeIdentifier("org.onebusaway.iphone.bookmark") }) else {
            return
        }

        item.loadObject(ofClass: NSString.self) { reading, error in
            guard let bookmarkToMoveID = reading as? NSString else { return }
            DispatchQueue.main.async {
                print("Bookmark to move: \(bookmarkToMoveID)")
            }
        }
        print("\(bookmarkGroupID.uuidString) -- \(index) -- \(items)")
        print("asdf!!")
    }
}

//struct BookmarksView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            BookmarksView(viewModel: BookmarkGroupViewModel.previewGroup)
//        }
//    }
//}

struct BookmarksDropDelegate: DropDelegate {
    @ObservedObject var bookmarksDAO: BookmarksDataModel

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: ["org.onebusaway.iphone.bookmark"])
        return false
    }
}
