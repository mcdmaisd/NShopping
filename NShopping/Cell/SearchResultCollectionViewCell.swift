//
//  SearchResultCollectionViewCell.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit
import RxSwift

final class SearchResultCollectionViewCell: BaseCollectionViewCell {
    private let productImageView = UIImageView()
    private let shopNameLabel = UILabel()
    private let productNameLabel = UILabel()
    private let priceLabel = UILabel()
    private(set) var likeButton = LikeButton()
    private(set) var disposeBag = DisposeBag()
        
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(shopNameLabel)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(likeButton)
    }
    
    override func configureLayout() {
        productImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(productImageView.snp.width)
        }
        
        likeButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(productImageView).offset(-10)
            make.size.equalTo(productImageView.snp.width).dividedBy(5)
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
    
    override func configureView() {
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

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        shopNameLabel.text = nil
        productNameLabel.text = nil
        priceLabel.text = nil
        likeButton.configureButton()
        disposeBag = DisposeBag()
    }
    
    func configureData(_ item: Item) {
        productImageView.kf.setImage(with: URL(string: item.image))
        shopNameLabel.text = item.mallName
        productNameLabel.text = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        priceLabel.text = "\((Int(item.lprice) ?? 0).formatted())"
        likeButton.configureButton(item.productId)
    }
}
