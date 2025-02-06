//
//  ViewController.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit
import OrderedCollections

class SearchViewController: BaseViewController {
    private let viewModel = SearchViewModel()
    private let outlineView = UIView()
    private let tableView = UITableView()
    private let noHistoryLabel = UILabel()
    private let recentSearchedHistoryLabel = UILabel()
    private let removeAllButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        binding()
    }
    
    private func binding() {
        viewModel.searchHistory.bind { list in
            self.toggleUI(list)
            self.tableView.reloadData()
        }
        
        viewModel.emptyKeyword.lazyBind { _ in
            self.presentAlert(message: Constants.alertMessage)
        }
        
        viewModel.searchResult.lazyBind { result in
            let vc = SearchResultViewController()
            vc.viewModel.result.value = result
            vc.viewModel.keyword = self.viewModel.keyword.value
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
        
    override func configureHierarchy() {
        view.addSubview(outlineView)
        outlineView.addSubview(removeAllButton)
        outlineView.addSubview(recentSearchedHistoryLabel)
        outlineView.addSubview(tableView)
        view.addSubview(noHistoryLabel)
    }
    
    override func configureLayout() {
        outlineView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        removeAllButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }

        recentSearchedHistoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.height.equalTo(removeAllButton)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(removeAllButton.snp.bottom).offset(5)
        }
        
        noHistoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func configureView() {
        outlineView.isHidden = true
        
        recentSearchedHistoryLabel.text = Constants.recentLabelText
        recentSearchedHistoryLabel.sizeToFit()
        
        var config = UIButton.Configuration.plain()
        config.title = Constants.removeAllText
        config.baseForegroundColor = .black
        removeAllButton.configuration = config
        removeAllButton.sizeToFit()
        removeAllButton.addTarget(self, action: #selector(removeAllButtonTapped), for: .touchUpInside)
        
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        noHistoryLabel.font = .boldSystemFont(ofSize: 20)
        noHistoryLabel.text = Constants.emptyHistoryText
        noHistoryLabel.sizeToFit()
        noHistoryLabel.backgroundColor = .clear
    }
}

extension SearchViewController {
    private func initNavigationBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Constants.searchBarPlaceHolder
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = Constants.title
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchHistoryTableViewCell.self, forCellReuseIdentifier: SearchHistoryTableViewCell.id)
    }
}

extension SearchViewController {
    private func toggleUI(_ list: OrderedSet<String>) {//
        outlineView.isHidden = list.isEmpty
        noHistoryLabel.isHidden = !list.isEmpty
    }
    
    private func search(_ keyword: String) {//
        let url = UrlComponent.Query.parameters(query: keyword).result
        
        NetworkManager.shared.requestAPI(url) { [self] data in
            let vc = SearchResultViewController()
            vc.keyword = keyword
            vc.result = data
            configureNavigationBar(vc)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    @objc
    private func removeButtonTapped(_ sender: UIButton) {
        viewModel.removeButtonTapped.value = sender.tag
    }
    
    @objc
    private func removeAllButtonTapped() {
        viewModel.removeAllButtonTapped.value = ()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchHistory.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.id, for: indexPath) as! SearchHistoryTableViewCell
        
        cell.cancelButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        cell.configureData(viewModel.searchHistory.value[row], row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        search(viewModel.searchHistory.value[indexPath.row])
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchButtonTapped.value = searchBar.text ?? ""
        view.endEditing(true)
        searchBar.text?.removeAll()
    }
}
