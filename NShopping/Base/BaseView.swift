//
//  BaseView.swift
//  MyMDB
//
//  Created by ilim on 2025-01-27.
//

import UIKit
import SnapKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureHierarchy() {}
    func configureLayout() {}
    func configureView() {}
    func addView(_ view: UIView) {
        addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
