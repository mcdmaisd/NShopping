//
//  SearchResultCollectionViewCell.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit
import Kingfisher
import SnapKit

class SearchResultCollectionViewCell: UICollectionViewCell {
    
    private let productImageView = UIImageView()
    private let shopNameLabel = UILabel()
    private let productNameLabel = UILabel()
    private let priceLabel = UILabel()
    
    static let id = getId()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        shopNameLabel.text = nil
        productNameLabel.text = nil
        priceLabel.text = nil
    }
    
    func configureData(_ item: Item) {
        productImageView.kf.setImage(with: URL(string: item.image))
        shopNameLabel.text = item.mallName
        productNameLabel.text = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        priceLabel.text = "\((Int(item.lprice) ?? 0).formatted())"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchResultCollectionViewCell: ViewConfiguration {
    func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(shopNameLabel)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
    }
    
    func configureLayout() {
        productImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(productImageView.snp.width)
        }
        
        shopNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(productImageView).inset(10)
            make.height.equalTo(22)
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(shopNameLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom)
            make.leading.equalTo(productNameLabel)
        }
    }
    
    func configureView() {
        productImageView.contentMode = .scaleToFill
        productImageView.layer.cornerRadius = 10
        productImageView.layer.masksToBounds = true
        
        shopNameLabel.font = .systemFont(ofSize: 14)
        shopNameLabel.textColor = .gray
        shopNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        productNameLabel.numberOfLines = 3
        productNameLabel.font = .systemFont(ofSize: 14)
        productNameLabel.textAlignment = .left
        productNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        priceLabel.sizeToFit()
        priceLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
}
