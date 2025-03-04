//
//  LikeButtonViewModel.swift
//  NShopping
//
//  Created by ilim on 2025-02-27.
//

import Foundation
import RxCocoa
import RxSwift

class LikeButtonViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let initialButtonStatus: PublishRelay<Int>
        let likeButtonTapped: Observable<Int>
    }
    
    struct Output {
        let isSelected: Driver<Bool>
    }
    
    private func checkTagIsContains(tag: Int) -> Bool {
        return U.shared.get(C.productKey, [Int]()).contains(tag)
    }
    
    func transform(input: Input) -> Output {
        let isSelected = PublishRelay<Bool>()

        input.initialButtonStatus
            .bind(onNext: { tag in
                let result = U.shared.get(C.productKey, [Int]()).contains(tag)
                isSelected.accept(result)
            })
            .disposed(by: disposeBag)
        
        input.likeButtonTapped
            .bind(with: self, onNext: { owner, tag in
                if tag == 0 {
                    isSelected.accept(false)
                    return
                }

                let hasValue = owner.checkTagIsContains(tag: tag)
                var list = U.shared.get(C.productKey, [Int]())
                
                if hasValue {
                    if let index = list.firstIndex(of: tag) {
                        list.remove(at: index)
                    }
                } else {
                    list.append(tag)
                }

                U.shared.set(list, C.productKey)
                presentToast(C.likeButtonMessages[!hasValue] ?? "")
                isSelected.accept(!hasValue)
            })
            .disposed(by: disposeBag)
        
        return Output(isSelected: isSelected.asDriver(onErrorJustReturn: false))
    }
}
