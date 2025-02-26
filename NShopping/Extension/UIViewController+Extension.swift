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
    
    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }
}
