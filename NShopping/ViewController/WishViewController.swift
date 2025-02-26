//
//  WishViewController.swift
//  NShopping
//
//  Created by ilim on 2025-02-26.
//

import UIKit

struct Product: Hashable {
    let id = UUID()
    let name: String
    let date = Date().dateToString()
}

enum Section {
    case main
}

final class WishViewController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>!
    private var list: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        configureUI()
        initCollectionView()
        configureDataSource()
        updateSnapshot()
    }
    
    private func initNavBar() {
        initNavigationBar()
        configureNavigationBar(self)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(list, toSection: .main)
        
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Product> { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.name
            content.textProperties.color = .black
            content.secondaryText = itemIdentifier.date
            content.secondaryTextProperties.color = .blue
            content.image = UIImage(systemName: "star.fill")
            content.imageProperties.tintColor = .systemMint
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listCell()
            backgroundConfig.backgroundColor = .white
            backgroundConfig.cornerRadius = 31
            backgroundConfig.strokeColor = .lightGray
            backgroundConfig.strokeWidth = 2
            cell.backgroundConfiguration = backgroundConfig
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        return layout
    }
    
    private func initNavigationBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "사고싶은 제품 입력"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "위시리스트"
    }
}

extension WishViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        list.remove(at: indexPath.item)
        updateSnapshot()
    }
}

extension WishViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        list.append(Product(name: searchBar.text ?? ""))
        updateSnapshot()
    }
}
