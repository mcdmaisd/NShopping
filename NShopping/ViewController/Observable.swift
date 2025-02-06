//
//  Observable.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//

import Foundation

class Observable<T> {
    
    private var closure: ((T) -> Void)?
    
    var value: T {
        didSet {
            closure?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
     
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        self.closure = closure
    }
    
    func lazyBind(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}
