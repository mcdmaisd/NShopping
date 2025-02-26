//
// SearchResultViewModel.swift
// NShopping
//
// Created by ilim on 2025-02-06.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel {
    private let disposeBag = DisposeBag()
    private var startIndex = UrlConstant.start
    var result: Shopping?
    var keyword: String?
    
    struct Input {
        let filterButtonTapped: Observable<Int>
        let pagination: Observable<[IndexPath]>
    }
    
    struct Output {
        let searchResult: BehaviorRelay<Shopping?>
        let selectedFilterButton: BehaviorRelay<Int>
        let scrollToTop: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let searchResult = BehaviorRelay<Shopping?>(value: result)
        let selectedFilterButton = BehaviorRelay<Int>(value: 0)
        let scrollToTop = PublishRelay<Bool>()
        
        input.filterButtonTapped
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, tag in
                selectedFilterButton.accept(tag)
                owner.startIndex = UrlConstant.start
                owner.search(filter: UrlConstant.sortingKeys[tag], index: owner.startIndex)
                    .subscribe(onNext: { shopping in
                        searchResult.accept(shopping)
                        scrollToTop.accept(true)
                    }, onError: { error in
                        showAlert(error.localizedDescription)
                    })
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.pagination
            .bind(with: self, onNext: { owner, indexPaths in
                guard let currentItems = searchResult.value?.items else { return }
                if currentItems.count - 8 <= indexPaths.last?.row ?? 0 {
                    owner.startIndex += UrlConstant.display
                    owner.search(filter: UrlConstant.sortingKeys[selectedFilterButton.value], index: owner.startIndex)
                        .subscribe(onNext: { shopping in
                            var updatedShopping = searchResult.value
                            updatedShopping?.items.append(contentsOf: shopping.items)
                            searchResult.accept(updatedShopping)
                            scrollToTop.accept(false)
                        }, onError: { error in
                            showAlert(error.localizedDescription)
                        })
                        .disposed(by: owner.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(searchResult: searchResult,
                      selectedFilterButton: selectedFilterButton,
                      scrollToTop: scrollToTop)
    }
    
    private func search(filter: String, index: Int) -> Observable<Shopping> {
        guard let keyword = keyword, !keyword.isEmpty else {
            return Observable.empty()
        }
        let url = UrlComponent.Query.parameters(query: keyword, sort: filter, start: index).result
        return NetworkManager.shared.requestAPI(url)
    }
    
    func setKeyword(_ keyword: String) {
        self.keyword = keyword
    }
}
