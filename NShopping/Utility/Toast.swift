//
//  Toast.swift
//  NShopping
//
//  Created by ilim on 2025-02-27.
//

import UIKit
import Toast

func presentToast(_ message: String) {
    var style = ToastStyle()
    
    style.messageColor = .white
    style.backgroundColor = .systemPink
    
    let window = UIApplication.shared.getCurrentScene()
    let center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)

    window.makeToast(message, duration: 1, point: center, title: nil, image: nil, style: style, completion: nil)
}

func presentLoading() {
    let window = UIApplication.shared.getCurrentScene()
    window.makeToastActivity(.center)
}

func hideLoading() {
    let window = UIApplication.shared.getCurrentScene()
    window.hideToastActivity()
}
