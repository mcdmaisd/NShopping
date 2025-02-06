//
//  SearchResultViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//

import Foundation

class SearchResultViewModel {
    private var previousIndex = 0

    var result: Observable<Shopping?> = Observable(nil)
    var scrollToTop = false
    var keyword: String?
    var startIndex = UrlConstant.start
    
    let filterButtonTapped: Observable<Int> = Observable(0)
    let selectedFilterButton: Observable<Int> = Observable(0)
    let pagination: Observable<[IndexPath]?> = Observable(nil)
    
    init() {
        filterButtonTapped.lazyBind { tag in
            if tag == self.previousIndex { return }
            self.filter(tag)
        }
        
        pagination.lazyBind { index in
            self.pagination(index ?? [])
        }
    }
    
    private func filter(_ filter: Int) {
        previousIndex = filter
        selectedFilterButton.value = filter
        search(UrlConstant.sortingKeys[filter])
    }
    
    private func fetchPage() {
        let filterIndex = selectedFilterButton.value
        let filter = UrlConstant.sortingKeys[filterIndex]
        search(filter, startIndex)
    }
    
    private func search(_ filter: String, _ index: Int = 1) {
        guard let keyword else { return }
        let url = UrlComponent.Query.parameters(query: keyword, sort: filter, start: index).result
        scrollToTop = index == 1 ? true : false

        NetworkManager.shared.requestAPI(url) { [weak self] (data: Shopping) in
            if index == 1 {
                self?.result.value?.items = data.items
            } else {
                self?.result.value?.items.append(contentsOf: data.items)
            }
        }
    }
    
    private func pagination(_ indexPaths: [IndexPath]) {
        guard let item = result.value else { return }
        
        if item.total <= startIndex { return }
        
        for index in indexPaths {
            if item.items.count - 4 == index.row {
                startIndex += UrlConstant.display
                fetchPage()
            }
        }
    }
}
