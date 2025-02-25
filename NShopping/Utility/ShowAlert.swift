//
//  ShowAlert.swift
//  MyMDB
//
//  Created by ilim on 2025-02-12.
//

import UIKit

func showAlert(_ message: String) {
    UIApplication.shared.getCurrentScene().rootViewController?.presentAlert(message: message)
}
