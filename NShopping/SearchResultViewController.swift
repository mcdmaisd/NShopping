//
//  SearchResultViewController.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    var result: Shopping?
    var keyword: String?
    
    private let totalLabel = UILabel()
    
    private var start = UrlConstant.start
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
        view.backgroundColor = .white
        title = keyword
        configureHierarchy()
        configureLayout()
        configureView()
        configureButtons()
        initCollectionView()
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
        
        if sortingButtons[index].isSelected { return }
        
        sortingButtons.forEach { $0.isSelected = $0.tag == index ? true : false }
        start = UrlConstant.start
        
        let sortingOption = UrlConstant.sortingKeys[index]
        let url = Url.Querys.parameters(query: keyword ?? "" , sort: sortingOption).result
        
        requestAPI(url) { [self] value in
            switch value {
            case .success(let success):
                result = success
                collecionView.reloadData()
                collecionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: true)
            case .failure(let failure):
                dump(failure)
            }
        }
    }
}

extension SearchResultViewController: ViewConfiguration {
    func configureHierarchy() {
        view.addSubview(totalLabel)
        view.addSubview(stackView)
        view.addSubview(collecionView)
    }
    
    func configureLayout() {
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
    
    func configureView() {
        totalLabel.text = "\(result?.total.formatted() ?? "") 개의 검색 결과"
        totalLabel.textColor = .systemPink

        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        result?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.id, for: indexPath) as! SearchResultCollectionViewCell
        
        guard let item = result?.items[row] else { return cell }
        cell.configureData(item)
        
        return cell
    }
}

extension SearchResultViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(#function, indexPaths)
        let tag = sortingButtons.filter { $0.isSelected }.first?.tag ?? -1
        guard let item = result else { return }
        let total = item.total
        if total <= start { return }
        for index in indexPaths {
            if item.items.count - 4 == index.row {
                start += UrlConstant.display
                let sortingOption = UrlConstant.sortingKeys[tag]
                let url = Url.Querys.parameters(query: keyword ?? "" , sort: sortingOption, start: start).result

                requestAPI(url) { [self] value in
                    switch value {
                    case .success(let success):
                        result?.items.append(contentsOf: success.items)
                        collecionView.reloadData()
                    case .failure(let failure):
                        dump(failure)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print(#function, indexPaths)
    }
    
    
}
