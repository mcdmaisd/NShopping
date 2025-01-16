//
//  UserDefaultsManager.swift
//  NShopping
//
//  Created by ilim on 2025-01-17.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    private let key = Constants.arrayUserDefaultsKey

    private init() { }

    var list: [String] {
        get {
            defaults.array(forKey: key) as? [String] ?? []
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
}
