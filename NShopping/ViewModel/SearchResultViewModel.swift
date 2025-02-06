//
//  SearchResultViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//

import Foundation

class SearchResultViewModel {
    var result: Observable<Shopping?> = Observable(nil)
    var keyword: String?
    
    let filterButtonTapped: Observable<Void?> = Observable(nil)
    
    init() {
        
    }
    
    
}
