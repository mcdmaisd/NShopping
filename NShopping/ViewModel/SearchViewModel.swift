//
//  SearchViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-06.
//

import Foundation

class SearchViewModel {
    //output
    let searchHistory = Observable(UserDefaultsManager.shared.read())
    let searchResult: Observable<Shopping?> = Observable(nil)
    let emptyKeyword: Observable<Void?> = Observable(nil)
    let keyword: Observable<String?> = Observable(nil)
    //input
    let searchButtonTapped: Observable<String?> = Observable(nil)
    let removeButtonTapped: Observable<Int?> = Observable(nil)
    let removeAllButtonTapped: Observable<Void> = Observable(())
        
    init () {
        searchButtonTapped.lazyBind { [weak self] keyword in
            guard let text = keyword?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            self?.getSearchResult(text)
        }
        removeButtonTapped.lazyBind { [weak self] index in
            guard let index else { return }
            self?.remove(index)
        }
        removeAllButtonTapped.lazyBind { [weak self] in
            self?.removeAll()
        }
    }
    
    private func getSearchResult(_ keyword: String) {
        if keyword.isEmpty { emptyKeyword.value = () }
        else {
            searchHistory.value.insert(keyword, at: 0)
            self.keyword.value = keyword
            setUserDefaults()
            search(keyword)
        }
    }
    
    private func remove(_ index: Int) {
        searchHistory.value.remove(at: index)
        setUserDefaults()
    }
    
    private func removeAll() {
        searchHistory.value.removeAll()
        setUserDefaults()
    }
    
    private func setUserDefaults() {
        UserDefaultsManager.shared.save(list: searchHistory.value)
    }
    
    private func search(_ keyword: String) {
        let url = UrlComponent.Query.parameters(query: keyword).result
        
        NetworkManager.shared.requestAPI(url) { [weak self] data in
            self?.searchResult.value = data
        }
    }
}
