//
//  SearchViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//

import RxCocoa
import RxSwift

class SearchViewModel {
    private let disposeBag = DisposeBag()
    private(set) var keyword = ""
    
    struct Input {
        let searchBarText: ControlProperty<String>
        let searchButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let searchResult: PublishRelay<Shopping>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishRelay<Shopping>()
        
        input.searchBarText
            .bind(with: self) { owner, value in
                owner.keyword = value
            }
            .disposed(by: disposeBag)
        
        input.searchButtonTapped
            .bind(with: self) { owner, _ in
                let keyword = owner.keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                owner.keyword = keyword
                guard !keyword.isEmpty, keyword.count > 1 else {
                    showAlert("검색어는 최소 2자 이상 입력하세요")
                    return
                }
                
                let url = UrlComponent.Query.parameters(query: keyword).result

                NetworkManager.shared.requestAPI(url)
                    .subscribe(with: self) { owner, response in
                        result.accept(response)
                    } onError: { owner, error in
                        showAlert(error.localizedDescription)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        return Output(searchResult: result)
    }
}
