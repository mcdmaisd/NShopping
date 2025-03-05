//
//  Table.swift
//  NShopping
//
//  Created by ilim on 2025-03-04.
//

import Foundation
import RealmSwift

final class Likes: Object {
    @Persisted(primaryKey: true) var productId: String
    @Persisted var title: String
    @Persisted var imageURL: String
    @Persisted var detailURL: String
    @Persisted var price: String
    @Persisted var mallName: String
    @Persisted(originProperty: "likes") var folder: LinkingObjects<Folder>
    
    convenience init(productId: String, title: String, imageURL: String, detailURL: String, price: String, mallName: String) {
        self.init()
        self.productId = productId
        self.title = title
        self.imageURL = imageURL
        self.detailURL = detailURL
        self.price = price
        self.mallName = mallName
    }
}

final class MyProduct: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var name: String
    @Persisted var date: String
    @Persisted(originProperty: "myProduct") var folder: LinkingObjects<Folder>

    convenience init(name: String) {
        self.init()
        self.name = name
        self.date = Date().dateToString()
    }
}
