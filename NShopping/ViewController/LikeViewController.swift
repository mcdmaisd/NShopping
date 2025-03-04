//
//  LikeViewController.swift
//  NShopping
//
//  Created by ilim on 2025-03-04.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift
import SnapKit

final class LikeViewController: BaseViewController {
    private let realm = try! Realm()
    private var list = PublishRelay<[Likes]>()
    private let disposeBag = DisposeBag()
    private var searchBar = UISearchBar()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout())
    
    override func configureHierarchy() {
        addSubView(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        collectionView.backgroundColor = .clear
        collectionView.register(SearchResultCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultCollectionViewCell.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        bind()
        loadObject()
    }
    
    deinit {
        print(self, #function)
    }
    
    private func initNavigationBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Constants.searchBarPlaceHolder
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "좋아요 목록"
        
        self.searchBar = searchController.searchBar
    }
    
    private func loadObject() {
        let data = realm.objects(Likes.self)
        list.accept(Array(data))
    }
    
    private func bind() {
        list.bind(to: collectionView.rx.items(
            cellIdentifier: SearchResultCollectionViewCell.id,
            cellType: SearchResultCollectionViewCell.self
        )) { [weak self] row, item, cell in
            guard let self else { return }
            
            let data = Item(
                title: item.title,
                link: item.detailURL,
                image: item.imageURL,
                lprice: item.price,
                mallName: item.mallName,
                productId: item.productId
            )
            
            cell.configureData(data)
            cell.likeButton.button.rx.tap
                .map { cell.likeButton.button.tag }
                .bind(with: self) { owner, tag in
                    let objects = owner.realm.objects(Likes.self).where { $0.productId == String(tag) }
                    
                    try? owner.realm.write {
                        owner.realm.delete(objects)
                    }
                    
                    owner.searchBar.text?.removeAll()
                    owner.loadObject()
                }
                .disposed(by: cell.disposeBag)
        }
        .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(with: self) { owner, text in
                let data = owner.realm.objects(Likes.self)
                
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    owner.list.accept(Array(data))
                    return
                }
                
                let filteredList = data.where {
                    $0.title.contains(text, options: .caseInsensitive)
                }
                
                owner.list.accept(Array(filteredList))
            }
            .disposed(by: disposeBag)
    }
}
