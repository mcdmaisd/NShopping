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
        configureUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = SearchResultViewModel.Input(
            filterButtonTapped: Observable.merge(
                sortingButtons.map { button in
                    button.rx.tap.map { _ in button.tag }
                }
            ),
            pagination: collectionView.rx.prefetchItems.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.searchResult
            .bind(with: self) { owner, shopping in
                owner.totalLabel.text = "\(shopping?.count.formatted() ?? "0")개의 검색 결과"
            }
            .disposed(by: disposeBag)
        
        output.searchResult
            .compactMap { $0 }
            .bind(to: collectionView.rx.items(cellIdentifier: SearchResultCollectionViewCell.id, cellType: SearchResultCollectionViewCell.self)) { row, result, cell in
                cell.configureData(result)
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
        title = "검색 결과"
        
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
        
        sortingButtons[0].isSelected = true
    }
    
    private func flowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsInLine: CGFloat = 2
        let inset: CGFloat = 10
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (numberOfItemsInLine + 1) * inset) / numberOfItemsInLine
        
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.6)
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = inset
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
        
        return layout
    }
}
