//
//  PrimitiveSequence+ToBolts.swift
//  RxToBolts
//
//  Created by Junmo Kim on 2017. 11. 5..
//  Copyright © 2017년 Junmo Kim. All rights reserved.
//

import Foundation
import RxSwift
import Bolts

extension PrimitiveSequence where Trait == SingleTrait, Element: AnyObject {
    /**
     Emit object to result on success. The result of `BFTask` is typed nullable `Element` but not intended emit `nil`.
     
     - parameter cancellationToken: Token can dispose `Single` Observable
     
     - returns: Element typed Bolts task
     */
    public func toBoltsTask(with cancellationToken: BFCancellationToken? = nil) -> BFTask<Element> {
        guard cancellationToken?.isCancellationRequested != true else { return .cancelled() }
        
        let source = BFTaskCompletionSource<Element>()
        let disposable = subscribe(onSuccess: source.set, onError: source.set)
        cancellationToken?.registerCancellationObserver { disposable.dispose() }
        
        return source.task
    }
}

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    /**
     Emit nil to result on success.
     
     - parameter cancellationToken: Token can dispose `Completable` Observable
     
     - returns: `AnyObject` typed Bolts task
     */
    public func toBoltsTask(with cancellationToken: BFCancellationToken? = nil) -> BFTask<AnyObject> {
        guard cancellationToken?.isCancellationRequested != true else { return .cancelled() }
        
        let source = BFTaskCompletionSource<AnyObject>()
        
        let disposable = subscribe(onCompleted: {
            source.set(result: nil)
        }, onError: source.set)
        cancellationToken?.registerCancellationObserver { disposable.dispose() }
        
        return source.task
    }
}

extension PrimitiveSequence where Trait == MaybeTrait, Element: AnyObject {
    /**
     Emit object to result on success and nil on completed.
     This will not emit multiple times as follow trait of `Maybe` and `BFTaskCompletionSource`.
     
     cf) https://github.com/ReactiveX/RxSwift/blob/4.0.0/Documentation/Traits.md#maybe
     
     - parameter cancellationToken: Token can dispose `Maybe` Observable
     
     - returns: Element typed Bolts task
     */
    public func toBoltsTask(with cancellationToken: BFCancellationToken? = nil) -> BFTask<Element> {
        guard cancellationToken?.isCancellationRequested != true else { return .cancelled()  }
        
        let source = BFTaskCompletionSource<Element>()
        let disposable = subscribe(onSuccess: source.set, onError: source.set, onCompleted: { source.set(result: nil) })
        cancellationToken?.registerCancellationObserver { disposable.dispose() }
        
        return source.task
    }
}
