//
//  ViewController.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit
import RxCocoa
import RxSwift

class SearchViewController: BaseViewController {
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    private let outlineView = UIView()
    private var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        binding()
    }
    
    private func binding() {
        let input = SearchViewModel.Input(
            searchBarText: searchBar.rx.text.orEmpty,
            searchButtonTapped: searchBar.rx.searchButtonClicked)
        let output = viewModel.transform(input: input)
        
        output.searchResult
            .bind(with: self) { owner, value in
                let vc = SearchResultViewController()
                vc.viewModel.result = value
                vc.viewModel.keyword = owner.viewModel.keyword
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController {
    private func initNavigationBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Constants.searchBarPlaceHolder
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = Constants.title
        
        self.searchBar = searchController.searchBar
    }
}
