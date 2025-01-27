//
//  ViewController.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//

import UIKit

class SearchViewController: BaseViewController {
    
    private let outlineView = UIView()
    private let tableView = UITableView()
    private let noHistoryLabel = UILabel()
    private let recentSearchedHistoryLabel = UILabel()
    private let removeAllButton = UIButton()
        
    private var searchHistoryList: [String] = UserDefaultsManager.shared.list {
        willSet {
            UserDefaultsManager.shared.list = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleUI()
        tableView.reloadData()
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
    private func toggleUI() {
        outlineView.isHidden = searchHistoryList.isEmpty
        noHistoryLabel.isHidden = !searchHistoryList.isEmpty
    }
    
    private func search(_ keyword: String) {
        let url = UrlComponent.Query.parameters(query: keyword).result
        
        NetworkManager.shared.requestAPI(url) { [self] data in
            let vc = SearchResultViewController()
            vc.keyword = keyword
            vc.result = data // vc.result type으로 추론, vc.result가 아닌 다른 타입의 변수/상수에 할당하는 순간 타입명시가 필요하다는 컴파일 에러 발생
            configureNavigationBar(vc)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func renewData() {
        toggleUI()
        tableView.reloadData()
    }
    
    @objc
    private func cancelButtonTapped(_ sender: UIButton) {
        searchHistoryList.remove(at: sender.tag)
        renewData()
    }
    
    @objc
    private func removeAllButtonTapped() {
        searchHistoryList.removeAll()
        renewData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.id, for: indexPath) as! SearchHistoryTableViewCell
        
        cell.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cell.configureData(searchHistoryList[row], row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        search(searchHistoryList[indexPath.row])
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text?.replacingOccurrences(of: " ", with: "") else { return }
        
        if !keyword.isEmpty {
            search(keyword)
            if searchHistoryList.contains(keyword) {
                let index = searchHistoryList.firstIndex(of: keyword) ?? -1
                searchHistoryList.remove(at: index)
            }
            searchHistoryList.insert(keyword, at: 0)
            view.endEditing(true)
        }
        
        searchBar.text?.removeAll()
    }
}
