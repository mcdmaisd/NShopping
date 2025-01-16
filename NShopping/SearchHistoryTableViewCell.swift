//
//  SearchHistoryTableViewCell.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit
import SnapKit

class SearchHistoryTableViewCell: UITableViewCell {

    private let clockImage = UIImageView()
    private let keywordLabel = UILabel()
    let cancelButton = UIButton()
    
    static let id = getId()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        keywordLabel.text = nil
    }
    
}

extension SearchHistoryTableViewCell: ViewConfiguration {
    func configureHierarchy() {
        contentView.addSubview(clockImage)
        contentView.addSubview(keywordLabel)
        contentView.addSubview(cancelButton)
    }
    
    func configureLayout() {
        clockImage.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.leading.verticalEdges.equalToSuperview()
        }
        
        keywordLabel.snp.makeConstraints { make in
            make.leading.equalTo(clockImage.snp.trailing).offset(10)
            make.verticalEdges.equalToSuperview()
            make.height.equalTo(clockImage)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.size.equalTo(clockImage.snp.height)
            make.leading.equalTo(keywordLabel.snp.trailing).inset(5)
        }
    }
    
    func configureView() {
        clockImage.image = UIImage(systemName: "clock")
        clockImage.tintColor = .black
        clockImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        clockImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        keywordLabel.font = .boldSystemFont(ofSize: 20)
        keywordLabel.textAlignment = .left
        
        cancelButton.tintColor = .black
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configureData(_ keyword: String, _ tag: Int) {
        keywordLabel.text = keyword
        cancelButton.tag = tag
    }
    
}