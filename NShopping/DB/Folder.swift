//
//  Folder.swift
//  NShopping
//
//  Created by ilim on 2025-03-06.
//

import Foundation
import RealmSwift

class Folder: Object {
    @Persisted var id: ObjectId
    @Persisted var name: String
    @Persisted var likes: List<Likes>
    @Persisted var myProduct: List<MyProduct>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
