//
//  UserDefaultsManager.swift
//  NShopping
//
//  Created by ilim on 2025-01-17.
//

import Foundation
import OrderedCollections

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private let defaults = UserDefaults.standard
    private let key = Constants.arrayUserDefaultsKey
    
    private var savedList: OrderedSet<String> = []

    private init() { }
    
    func save(list: OrderedSet<String>) {
        do {
            let encodedData = try encoder.encode(list)
            defaults.set(encodedData, forKey: key)
        } catch {
            print("Failed to save")
        }
    }

    func read() -> OrderedSet<String> {
        if let savedData = defaults.object(forKey: key) as? Data {
            do{
                savedList = try decoder.decode(OrderedSet<String>.self, from: savedData)
                return savedList
            } catch {
                print("Failed to read")
            }
        }
        
        return savedList
    }
}
