//
//  SearchViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//
import Foundation
import OrderedCollections
import RxCocoa
import RxSwift

class SearchViewModel {
    private let disposeBag = DisposeBag()
    private(set) var keyword = ""
    private var searchList = U.shared.read()
    
    struct Input {
        let searchBarText: ControlProperty<String>
        let searchButtonTapped: ControlEvent<Void>
        let cancelButtonTapped: PublishSubject<Int>
        let tableViewCellTapped: ControlEvent<IndexPath>
    }
    
    struct Output {
        let searchResult: PublishRelay<Shopping>
        let searchHistory: BehaviorRelay<OrderedSet<String>>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishRelay<Shopping>()
        let set = BehaviorRelay<OrderedSet<String>>(value: U.shared.read())
        
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
                
                if let index = owner.searchList.firstIndex(of: owner.keyword) {
                    owner.searchList.remove(at: index)
                }
                
                owner.searchList.insert(owner.keyword, at: 0)
                set.accept(owner.searchList)
                U.shared.save(list: set.value)
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
        
        input.cancelButtonTapped
            .bind(with: self) { owner, tag in
                owner.searchList.remove(at: tag)
                set.accept(owner.searchList)
                U.shared.save(list: set.value)
            }
            .disposed(by: disposeBag)
        
        input.tableViewCellTapped
            .bind(with: self) { owner, indexPath in
                let keyword = owner.searchList[indexPath.row]
                let index = owner.searchList.firstIndex(of: keyword)
                owner.keyword = keyword
                owner.searchList.remove(at: index!)
                owner.searchList.insert(keyword, at: 0)
                set.accept(owner.searchList)
                U.shared.save(list: set.value)
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
        
        return Output(searchResult: result, searchHistory: set)
    }
}
