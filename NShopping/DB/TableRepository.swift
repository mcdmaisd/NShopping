//
//  Repository.swift
//  NShopping
//
//  Created by ilim on 2025-03-06.
//

import Foundation
import RealmSwift

protocol Repository {
    func getFileURL()
    func fetchAll() -> Results<MyProduct>
    func deleteItem(data: MyProduct)
    func createItemInFolder(folder: Folder, data: MyProduct)
}

final class TableRepository: Repository {
    private let realm = try! Realm()
    
    func getFileURL() {
        print(realm.configuration.fileURL ?? "No URL")
    }
    
    func fetchAll() -> Results<MyProduct> {
        let data = realm.objects(MyProduct.self)
        return data
    }
    
    func createItemInFolder(folder: Folder, data: MyProduct) {
        do {
            try realm.write {
                folder.myProduct.append(data)
                print("Data Saved")
            }
        } catch {
            print("Failed to save data")
        }
    }

    
    func deleteItem(data: MyProduct) {
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch {
            print("Failed to delete")
        }
    }
}
