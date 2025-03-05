//
//  FolderViewController.swift
//  NShopping
//
//  Created by ilim on 2025-03-06.
//

import UIKit
import RealmSwift

class FolderViewController: BaseViewController {
    let tableView = UITableView()
    var list: Results<Folder>!
    let repository: FolderRepository = FolderTableRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list = repository.fetchAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = repository.fetchAll()
        tableView.reloadData()
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    override func configureView() {
        title = "Folder List"
        view.backgroundColor = .white
        tableView.rowHeight = 130
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderTableViewCell.id)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension FolderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.id, for: indexPath) as! FolderTableViewCell
        let data = list[indexPath.row]
        
        cell.titleLabel.text = data.name
        cell.subTitleLabel.text = "\(data.myProduct.count)개"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = list[indexPath.row]
        let vc = WishViewController()
        vc.wishlist = data.myProduct
        vc.id = data.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
