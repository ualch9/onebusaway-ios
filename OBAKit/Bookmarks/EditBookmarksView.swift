//
//  EditBookmarksView.swift
//  OBAKit
//
//  Created by Alan Chu on 11/3/21.
//

import SwiftUI

struct EditBookmarksView: View {
    @ObservedObject var bookmarksDAO: BookmarksDataModel

    var body: some View {
        List(bookmarksDAO.groups) { group in
            Section {
                ForEach(group.bookmarks) { bookmark in
                    Text(bookmark.name)
                }
                .onMove(perform: onMove)
            } header: {
                Text(group.name)
            }
        }
    }

    func onMove(from originIndexes: IndexSet, to destinationIndex: Int) {
//        for origin in originIndexes {
//            bookmarksDAO
//        }
//        bookmarksDAO.groups[origin.]
//        let section = bookmarksSections[indexPath.section]
//        let row = section.allRows[indexPath.row] as! NameRow // swiftlint:disable:this force_cast
//        guard let id = UUID(optionalUUIDString: row.tag) else { return nil }
//
//        return application.userDataStore.findBookmark(id: id)
    }
}

//struct EditBookmarksView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditBookmarksView()
//    }
//}
