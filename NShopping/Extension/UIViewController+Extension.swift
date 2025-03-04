//
//  UIViewController+Extension.swift
//  NShopping
//
//  Created by ilim on 2025-01-15.
//
import UIKit

extension UIViewController {
    func presentAlert(message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.okActionTitle, style: .default))
        present(alert, animated: true)
    }
    
    func configureNavigationBar(_ vc: UIViewController) {
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(back))
        let image = UIImage(systemName: Constants.backImageName)

        backBarButtonItem.tintColor = .black
        backBarButtonItem.image = image
        vc.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    func configureRightBarButtonItem(_ vc: UIViewController ,_ title: String? = nil, _ image: String? = nil) {
        let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        
        barButtonItem.tintColor = .black
        
        if let image {
            let buttonImage = UIImage(systemName: image)
            barButtonItem.image = buttonImage
        }
        
        vc.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func flowLayout() -> UICollectionViewFlowLayout {
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
    
    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }
}
