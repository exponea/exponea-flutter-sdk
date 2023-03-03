//
//  AppInboxStyle.swift
//  exponea
//
//  Created by Adam Mihalik on 02/03/2023.
//

import Foundation

class AppInboxStyle {
    var appInboxButton: ButtonStyle?
    var detailView: DetailViewStyle?
    var listView: ListScreenStyle?

    init(appInboxButton: ButtonStyle? = nil, detailView: DetailViewStyle? = nil, listView: ListScreenStyle? = nil) {
        self.appInboxButton = appInboxButton
        self.detailView = detailView
        self.listView = listView
    }
}
