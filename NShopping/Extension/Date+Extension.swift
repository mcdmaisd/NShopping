//
//  String+Extension.swift
//  MyMDB
//
//  Created by ilim on 2025-01-27.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yy.MM.dd"
        
        return formatter.string(from: self)
    }
}
