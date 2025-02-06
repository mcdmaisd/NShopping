//
//  SearchResultViewController.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit

class SearchResultViewController: BaseViewController {
    let viewModel = SearchResultViewModel()
    
    private let totalLabel = UILabel()

    private var stackView = UIStackView()
    private var sortingButtons: [UIButton] = []
    
    private lazy var collecionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout())
    private lazy var sortingButton = { (_ title: String, _ tag: Int) in
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = title
        config.buttonSize = .small
        button.configuration = config
        button.tag = tag
        button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
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
        title = viewModel.keyword
        configureNavigationBar(self)
        configureButtons()
        initCollectionView()
        binding()
    }
    
    private func binding() {
        viewModel.selectedFilterButton.bind { tag in
            for button in self.sortingButtons {
                if button.tag == tag {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
        }
        
        viewModel.result.bind { _ in
            self.collecionView.reloadData()
            if self.viewModel.scrollToTop {
                self.collecionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
            }
        }
    }
    
    override func configureHierarchy() {
        view.addSubview(totalLabel)
        view.addSubview(stackView)
        view.addSubview(collecionView)
    }
    
    override func configureLayout() {
        totalLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }

        collecionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(10)
        }
    }
    
    override func configureView() {
        totalLabel.text = "\(viewModel.result.value?.total.formatted() ?? "")\(Constants.searchResultSuffix)"
        totalLabel.textColor = .systemPink

        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
    }
}

extension SearchResultViewController {
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
    
    private func initCollectionView() {
        collecionView.delegate = self
        collecionView.dataSource = self
        collecionView.prefetchDataSource = self
        collecionView.register(SearchResultCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultCollectionViewCell.id)
    }
    
    private func configureButtons() {
        for (i, title) in UrlConstant.sortingTitles.enumerated() {
            let button = sortingButton(title, i)
            
            stackView.addArrangedSubview(button)
            sortingButtons.append(button)
        }
        
        sortingButtons[0].isSelected = true
    }
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        viewModel.filterButtonTapped.value = index
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.result.value?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.id, for: indexPath) as! SearchResultCollectionViewCell
        
        guard let item = viewModel.result.value?.items[row] else { return cell }
        cell.configureData(item)
        
        return cell
    }
}

extension SearchResultViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.pagination.value = indexPaths
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print(#function, indexPaths)
    }
}
