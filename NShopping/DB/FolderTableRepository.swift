//
//  FolderRepository.swift
//  NShopping
//
//  Created by ilim on 2025-03-06.
//

import Foundation
import RealmSwift

protocol FolderRepository {
    func createItem(name: String)
    func fetchAll() -> Results<Folder>
}

final class FolderTableRepository: FolderRepository {
    private let realm = try! Realm()
    
    func createItem(name: String) {
        let emptyFolder = realm.objects(Folder.self).where { $0.name == name }.isEmpty
        
        if emptyFolder {
            do {
                try realm.write {
                    let folder = Folder(name: name)
                    realm.add(folder)
                }
            } catch {
                print("fail to create folder")
            }
        } else {
            print("\(name) folder already exists")
        }
    }

    func fetchAll() -> Results<Folder> {
        return realm.objects(Folder.self)
    }
}
