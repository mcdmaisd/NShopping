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
    private var isNotFinished = false
    var result: Shopping?
    var keyword: String?
    
    struct Input {
        let filterButtonTapped: Observable<Int>
        let pagination: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let keyword: BehaviorRelay<String>
        let searchResult: BehaviorRelay<Shopping?>
        let selectedFilterButton: BehaviorRelay<Int>
        let scrollToTop: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let keyword = BehaviorRelay<String>(value: keyword ?? "")
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
                owner.checkDuplication(searchResult.value!)
                if owner.isNotFinished { return }
                guard let currentItems = searchResult.value?.items else { return }
                if currentItems.count - 15 <= (indexPaths.last?.row ?? 0) && !owner.isNotFinished {
                    if owner.startIndex > searchResult.value?.total ?? 0 { return }
                    owner.isNotFinished = true
                    owner.startIndex += UrlConstant.display
                    owner.search(filter: UrlConstant.sortingKeys[selectedFilterButton.value], index: owner.startIndex)
                        .subscribe(onNext: { shopping in
                            var updatedShopping = searchResult.value
                            updatedShopping?.items.append(contentsOf: shopping.items)
                            searchResult.accept(updatedShopping)
                            owner.isNotFinished = false
                        }, onError: { error in
                            showAlert(error.localizedDescription)
                        })
                        .disposed(by: owner.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(keyword: keyword,
                      searchResult: searchResult,
                      selectedFilterButton: selectedFilterButton,
                      scrollToTop: scrollToTop)
    }
    
    func checkDuplication(_ data: Shopping) {
        let list = data.items.map { $0.productId }
        let setList = Set(list)
        print("result:", list.count == setList.count, "list count: \(list.count), set count: \(setList.count)")
    }
    
    private func search(filter: String, index: Int) -> Observable<Shopping> {
        guard let keyword = keyword, !keyword.isEmpty else {
            return Observable.empty()
        }
        let url = UrlComponent.Query.parameters(query: keyword, sort: filter, start: index).result
        
        return NetworkManager.shared.requestAPI(url)
    }
}
