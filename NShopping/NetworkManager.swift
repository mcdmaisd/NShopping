//
//  RequestAPI.swift
//  NShopping
//
//  Created by ilim on 2025-01-16.
//

import UIKit
import Alamofire

func requestAPI<T: Codable>(_ url: String, _ completion: @escaping (T) -> Void) {
    let header: HTTPHeaders = [
        "X-Naver-Client-Id": Naver.id,
        "X-Naver-Client-Secret": Naver.secret
    ]
    AF.request(url, method: .get, headers: header)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                dump(error)
        }
    }
}

