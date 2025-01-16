//
//  RequestAPI.swift
//  NShopping
//
//  Created by ilim on 2025-01-16.
//

import UIKit
import Alamofire

func requestAPI(_ url: String, _ completion: @escaping (Result<Shopping, Error>) -> Void) {
    let header: HTTPHeaders = [
        "X-Naver-Client-Id": Naver.id,
        "X-Naver-Client-Secret": Naver.secret
    ]
    AF.request(url, method: .get, headers: header).responseDecodable(of: Shopping.self) { response in
        switch response.result {
        case.success(let value):
            completion(.success(value))
        case.failure(let error):
            dump(error)
        }
    }
}

