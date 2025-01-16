//
//  Constants.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import Foundation

struct UrlConstant {
    static let display = 30
    static let start = 1
    static let sortingKeys = ["sim", "date", "dsc", "asc"]
    static let sortingTitles = ["정확도", "날짜순", "가격높은순", "가격낮은순"]
}

enum UrlComponent: String {
    case baseUrl = "https://openapi.naver.com/v1/search/shop.json?"
    case queryPrefix = "query="
    case sortPrefix = "&sort="
    case displayPrefix = "&display="
    case startPrefix = "&start="
    
    enum Query {
        case parameters(
            query: String,
            sort: String = UrlConstant.sortingKeys[0],
            display: Int = UrlConstant.display,
            start: Int = UrlConstant.start
        )
        
        var result: String {
            switch self {
            case .parameters(let query, let sort, let display, let start):
                return "\(baseUrl.rawValue)\(queryPrefix.rawValue)\(query)\(sortPrefix.rawValue)\(sort)\(displayPrefix.rawValue)\(display)\(startPrefix.rawValue)\(start)"
            }
        }
    }
}
