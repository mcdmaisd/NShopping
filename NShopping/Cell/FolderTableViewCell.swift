//
//  FolderTableViewCell.swift
//  NShopping
//
//  Created by ilim on 2025-03-06.
//

import UIKit
import SnapKit

class FolderTableViewCell: UITableViewCell {
    let thumbnailImageView = UIImageView()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let overviewLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func configureLayout() {
        thumbnailImageView.snp.makeConstraints { make in
          make.leading.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
          make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
          make.trailing.top.equalTo(contentView.safeAreaLayoutGuide).inset(16)
          make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
          make.height.equalTo(18)
        }
        
        subTitleLabel.snp.makeConstraints { make in
          make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
          make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
          make.top.equalTo(titleLabel.snp.bottom)
          make.height.equalTo(18)
        }
        
        overviewLabel.snp.makeConstraints { make in
          make.trailing.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(16)
          make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
          make.top.equalTo(subTitleLabel.snp.bottom)
        }
    }
    
    private func configureHierarchy() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(overviewLabel)
    }
    
    private func configureView() {
        thumbnailImageView.contentMode = .scaleAspectFill
        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 13)
    }
}
