//
//  RequestAPI.swift
//  NShopping
//
//  Created by ilim on 2025-01-16.
//

import Foundation
import Alamofire
import RxSwift

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    func requestAPI(_ url: String) -> Observable<Shopping> {
        return Observable.create { observer in
            let headers: HTTPHeaders = [
                "X-Naver-Client-Id": Naver.id,
                "X-Naver-Client-Secret": Naver.secret
            ]
            let request = AF.request(url, method: .get, headers: headers)
            request.responseDecodable(of: Shopping.self) { response in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure:
                    if let data = response.data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.apiError(errorResponse.errorMessage))
                        } catch {
                            observer.onError(NetworkError.unknown(error))
                        }
                    } else if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 400:
                            observer.onError(NetworkError.statusCodeError(400, "잘못된 요청입니다."))
                        case 401:
                            observer.onError(NetworkError.statusCodeError(401, "인증 실패입니다."))
                        case 404:
                            observer.onError(NetworkError.statusCodeError(404, "요청한 리소스를 찾을 수 없습니다."))
                        case 500:
                            observer.onError(NetworkError.statusCodeError(500, "서버 오류입니다."))
                        default:
                            observer.onError(NetworkError.statusCodeError(statusCode, "알 수 없는 오류가 발생했습니다."))
                        }
                    } else {
                        observer.onError(NetworkError.invalidResponse)
                    }
                }
            }
            return Disposables.create { request.cancel() }
        }
    }
}
