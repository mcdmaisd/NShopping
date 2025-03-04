//
// SearchResultViewController.swift
// NShopping
//
// Created by ilim on 2025-01-15.
//

import UIKit
import RxCocoa
import RxSwift

class SearchResultViewController: BaseViewController {
    let viewModel = SearchResultViewModel()
    private let disposeBag = DisposeBag()
    private let likeButton = PublishRelay<Int>()

    private let totalLabel = UILabel()
    private var stackView = UIStackView()
    private var sortingButtons: [UIButton] = []
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout())
    private lazy var sortingButton = { (_ title: String, _ tag: Int) in
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = title
        config.buttonSize = .small
        button.configuration = config
        button.tag = tag
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.configurationUpdateHandler = { btn in
            switch btn.state {
            case .selected:
                btn.configuration?.baseBackgroundColor = .white
                btn.configuration?.baseForegroundColor = .black
                btn.configuration?.background.strokeColor = .black
            default:
                btn.configuration?.baseBackgroundColor = .black
                btn.configuration?.baseForegroundColor = .white
            }
        }
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(self)
        configureUI()
        bind()
    }
    
    private func bind() {
        let input = SearchResultViewModel.Input(
            filterButtonTapped: Observable.merge(
                sortingButtons.map { button in
                    button.rx.tap.map { _ in button.tag }
                }
            ),
            pagination: collectionView.rx.prefetchItems,
            likeButtonTapped: likeButton
        )
        
        let output = viewModel.transform(input: input)
        
        output.keyword
            .bind(with: self) { owner, title in
                owner.title = title
            }
            .disposed(by: disposeBag)
        
        output.searchResult
            .bind(with: self) { owner, shopping in
                owner.totalLabel.text = "\(shopping?.total.formatted() ?? "0")개의 검색 결과"
            }
            .disposed(by: disposeBag)
        
        output.searchResult
            .compactMap { $0?.items }
            .bind(to: collectionView.rx.items(
                cellIdentifier: SearchResultCollectionViewCell.id,
                cellType: SearchResultCollectionViewCell.self)) { [weak self] row, result, cell in
                    guard let self else { return }
                    cell.configureData(result)
                    cell.likeButton.button.rx.tap
                        .map { row }
                        .bind(to: likeButton)
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: disposeBag)
        
        output.selectedFilterButton
            .bind(with: self) { owner, tag in
                owner.sortingButtons.forEach { $0.isSelected = ($0.tag == tag) }
            }
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .bind(with: self) { owner, shouldScroll in
                if shouldScroll {
                    owner.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.addSubview(totalLabel)
        view.addSubview(stackView)
        view.addSubview(collectionView)
        
        collectionView.register(SearchResultCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultCollectionViewCell.id)
        
        totalLabel.snp.makeConstraints { make in make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10) }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(30)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        
        for (i, title) in UrlConstant.sortingTitles.enumerated() {
            let button = sortingButton(title, i)
            
            stackView.addArrangedSubview(button)
            sortingButtons.append(button)
        }
    }
}
