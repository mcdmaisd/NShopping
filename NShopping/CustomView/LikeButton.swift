//
//  LikeButton.swift
//  MyMDB
//
//  Created by ilim on 2025-01-27.
//

import UIKit
import RxCocoa
import RxSwift

final class LikeButton: BaseView {
    private let viewModel = LikeButtonViewModel()
    private let disposeBag = DisposeBag()
    private let initialStatusRelay = PublishRelay<Int>()
    private let button = UIButton()
        
    override func configureHierarchy() {
        addView(button)
    }
    
    override func configureLayout() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureView() {
        clipsToBounds = true
        bind()
    }
    
    private func bind() {
        let input = LikeButtonViewModel.Input(
            initialButtonStatus: initialStatusRelay.asObservable(),
            likeButtonTapped: button.rx.tap.map { self.button.tag })
        let output = viewModel.transform(input: input)
        
        output.isSelected
            .bind(with: self) { owner, result in
                owner.button.isSelected = result
            }
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    func configureButton(_ id: String = "") {
        let tag = Int(id) ?? 0
        initialStatusRelay.accept(tag)

        var config = UIButton.Configuration.filled()
        
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemPink

        button.configuration = config
        button.tag = tag
        button.configurationUpdateHandler = { btn in
            switch btn.state {
            case .selected:
                btn.configuration?.image = UIImage(systemName: C.heartFill)
            default:
                btn.configuration?.image = UIImage(systemName: C.heart)
            }
        }
    }
}
