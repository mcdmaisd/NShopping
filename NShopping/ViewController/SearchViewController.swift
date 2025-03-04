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
    private let tableView = UITableView()
    private let removeButtonTapped = PublishSubject<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        configureRightBarButtonItem(self, nil, "list.bullet")
        initTableView()
        binding()
    }
    
    override func configureHierarchy() {
        addSubView(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    private func initTableView() {
        tableView.register(SearchHistoryTableViewCell.self, forCellReuseIdentifier: SearchHistoryTableViewCell.id)
    }
    
    private func binding() {
        let input = SearchViewModel.Input(
            searchBarText: searchBar.rx.text.orEmpty,
            searchButtonTapped: searchBar.rx.searchButtonClicked,
            cancelButtonTapped: removeButtonTapped,
            tableViewCellTapped: tableView.rx.itemSelected)
        let output = viewModel.transform(input: input)
        
        output.searchResult
            .bind(with: self) { owner, value in
                let vc = SearchResultViewController()
                vc.viewModel.result = value
                vc.viewModel.keyword = owner.viewModel.keyword
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)

        output.searchHistory
            .bind(to: tableView.rx.items(cellIdentifier: SearchHistoryTableViewCell.id, cellType: SearchHistoryTableViewCell.self)) { [weak self] row, keyword, cell in
                guard let self else { return }
                cell.selectionStyle = .none
                cell.configureData(keyword, row)
                cell.cancelButton.rx.tap
                    .map { cell.cancelButton.tag }
                    .bind(to: removeButtonTapped)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(LikeViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController {
    private func initNavigationBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Constants.searchBarPlaceHolder
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = Constants.title
        
        self.searchBar = searchController.searchBar
    }
}
