//
//  ShoppingItem.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import Foundation

struct Shopping: Codable {
    let total: Int
    let start: Int
    let display: Int
    var items: [Item]
}

struct Item: Codable {
    let title: String
    let link: String
    let image: String
    let lprice: String
    let mallName: String
    let productId: String
}
