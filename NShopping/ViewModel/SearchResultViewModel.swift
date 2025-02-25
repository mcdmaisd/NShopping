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
        let searchResult: BehaviorRelay<[Item]?>
        let selectedFilterButton: BehaviorRelay<Int>
        let scrollToTop: PublishRelay<Bool>
    }

    func transform(input: Input) -> Output {
        let searchResult = BehaviorRelay<[Item]?>(value: result?.items)
        let selectedFilterButton = BehaviorRelay<Int>(value: 0)
        let scrollToTop = PublishRelay<Bool>()

        input.filterButtonTapped
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] filterIndex in
                guard let self = self else { return }
                selectedFilterButton.accept(filterIndex)
                self.startIndex = UrlConstant.start
                self.search(filter: UrlConstant.sortingKeys[filterIndex], index: self.startIndex)
                    .subscribe(onNext: { shopping in
                        searchResult.accept(shopping.items)
                        scrollToTop.accept(true)
                    }, onError: { error in
                        showAlert(error.localizedDescription)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        input.pagination
            .subscribe(onNext: { [weak self] indexPaths in
                guard let self = self else { return }
                guard let currentItems = searchResult.value else { return }
                if currentItems.count - 8 <= indexPaths.last?.row ?? 0 {
                    self.startIndex += UrlConstant.display
                    self.search(filter: UrlConstant.sortingKeys[selectedFilterButton.value], index: self.startIndex)
                        .subscribe(onNext: { shopping in
                            var updatedShopping = searchResult.value
                            updatedShopping?.append(contentsOf: shopping.items)
                            searchResult.accept(updatedShopping)
                            scrollToTop.accept(false)
                        }, onError: { error in
                            showAlert(error.localizedDescription)
                        })
                        .disposed(by: self.disposeBag)
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
