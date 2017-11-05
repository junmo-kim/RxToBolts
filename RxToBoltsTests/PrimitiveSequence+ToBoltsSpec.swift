//
//  PrimitiveSequence+ToBoltsSpec.swift
//  RxToBoltsTests
//
//  Created by Junmo Kim on 2017. 11. 5..
//  Copyright © 2017년 Junmo Kim. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import Bolts
@testable import RxToBolts

class PrimitiveSequenceToBoltsSpec: QuickSpec {
    override func spec() {
        describe("Convert Single trait observable to Bolts") {
            var error: Error?
            var result: NSNumber?
            var count: Int = 0
            
            beforeEach {
                error = nil
                result = nil
                count = 0
            }
            
            context("synchronous result") {
                it("expected to have success result", closure: {
                    let single = Single<NSNumber>.just(1)
                    
                    expect(count).to(equal(0))
                    
                    single.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(equal(NSNumber(value: 1)))
                    expect(count).to(equal(1))
                })
                
                it("expected to have error result") {
                    let single = Single<NSNumber>.error(NSError(domain: "TestError", code: 0, userInfo: nil))
                    
                    expect(count).to(equal(0))
                    
                    single.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.domain).to(equal("TestError"))
                    expect(result).to(beNil())
                    expect(count).to(equal(1))
                }
                
                it("expected to not call success block when error result") {
                    let single = Single<NSNumber>.error(NSError(domain: "TestError", code: 0, userInfo: nil))
                    
                    expect(count).to(equal(0))
                    
                    single.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(beNil())
                    expect(count).to(equal(0))
                }
            }
            
            context("asynchronous result") {
                it("expected to have success result") {
                    let single = Single<NSNumber>.just(1).delay(0.3, scheduler: MainScheduler.asyncInstance)
                    
                    single.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        return nil
                    })
                    
                    expect(error).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).to(beNil())
                    expect(result).toEventually(equal(NSNumber(value: 1)), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to have error result") {
                    let single = Single<NSNumber>.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(SingleEvent.error(NSError(domain: "TestError", code: 0, userInfo: nil)))
                        }
                        return Disposables.create()
                    })
                    
                    single.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect((error as NSError?)?.domain).toEventually(equal("TestError"), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                }
            }
        }
        
        describe("Convert Completable trait observable to Bolts") {
            var completable: Completable!
            var error: Error?
            var result: AnyObject?
            var count: Int = 0
            
            context("synchronous completed result", {
                beforeEach {
                    error = NSError(domain: "TestError", code: -1, userInfo: nil)
                    result = NSNull()
                    
                    completable = Completable.create(subscribe: { observer -> Disposable in
                        observer(.completed)
                        return Disposables.create()
                    })
                }
                
                it("expected to emit nil") {
                    expect(error).notTo(beNil())
                    expect(result).notTo(beNil())
                    
                    completable.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(beNil())
                }
                
                it("expected to call success block") {
                    expect(error).notTo(beNil())
                    expect(result).notTo(beNil())
                    
                    completable.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(beNil())
                }
            })
            
            context("synchronous error result") {
                beforeEach {
                    error = NSError(domain: "TestError", code: -1, userInfo: nil)
                    result = NSNull()
                    count = 0
                    
                    completable = Completable.create(subscribe: { observer -> Disposable in
                        observer(.error(NSError(domain: "TestError", code: 123, userInfo: nil)))
                        return Disposables.create()
                    })
                }
                
                it("expected to have error result") {
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.code).to(equal(123))
                    expect(result).to(beNil())
                    expect(count).to(equal(1))
                }
                
                it("expected to not call success block when error result") {
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).notTo(beNil())
                    expect(result as! NSNull?).to(equal(NSNull()))
                    expect(count).to(equal(0))
                }
            }
            
            context("asynchronous completed result") {
                beforeEach {
                    error = NSError(domain: "TestError", code: -1, userInfo: nil)
                    result = NSNull()
                    count = 0
                    
                    completable = Completable.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.completed)
                        }
                        return Disposables.create()
                    })
                }
                
                it("expected to emit nil") {
                    expect(error).notTo(beNil())
                    expect(result).notTo(beNil())
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        count += 1
                        return nil
                    })
                    
                    expect(error).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to call success block") {
                    expect(error).notTo(beNil())
                    expect(result).notTo(beNil())
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        count += 1
                        return nil
                    })
                    
                    expect(error).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
            }
            
            context("asynchronous error result") {
                beforeEach {
                    error = NSError(domain: "TestError", code: -1, userInfo: nil)
                    result = NSNull()
                    count = 0
                    
                    completable = Completable.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.error(NSError(domain: "TestError", code: 123, userInfo: nil)))
                        }
                        return Disposables.create()
                    })
                }
                
                it("expected to have error result") {
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.code).toEventually(equal(123), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to not call success block when error result") {
                    expect(count).to(equal(0))
                    
                    completable.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.code).toEventually(equal(-1), timeout: 0.6, pollInterval: 0.1)
                    expect(result as! NSNull?).toEventually(equal(NSNull()), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(0), timeout: 0.6, pollInterval: 0.1)
                }
            }
        }
        
        describe("Convert Maybe trait observable to Bolts") {
            context("synchronous result") {
                var maybe: Maybe<NSNumber>!
                var error: Error?
                var result: NSNumber?
                var count = 0
                
                beforeEach {
                    error = nil
                    result = nil
                    count = 0
                }
                
                it("expected to emit success result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        observer(.success(NSNumber(value: 3)))
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(equal(NSNumber(value: 3)))
                    expect(count).to(equal(1))
                }
                
                it("expected to nil result with empty error when completed event") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        observer(.completed)
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(beNil())
                    expect(count).to(equal(1))
                }
                
                it("expected to emit error result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        observer(.error(NSError(domain: "TestError", code: 456, userInfo: nil)))
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.code).to(equal(456))
                    expect(result).to(beNil())
                    expect(count).to(equal(1))
                }
                
                it("expected to not call success block when error result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        observer(.error(NSError(domain: "TestError", code: 456, userInfo: nil)))
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).to(beNil())
                    expect(result).to(beNil())
                    expect(count).to(equal(0))
                }
            }
            
            context("asynchronous result") {
                var maybe: Maybe<NSNumber>!
                var error: Error?
                var result: NSNumber?
                var count = 0
                
                beforeEach {
                    error = NSError(domain: "InitialError", code: 0, userInfo: nil)
                    result = NSNumber(value: -1)
                    count = 0
                }
                
                it("expected to emit success result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.success(NSNumber(value: 4)))
                        }
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(equal(NSNumber(value: 4)), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to nil result with empty error when completed event") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.completed)
                        }
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to emit error result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.error(NSError(domain: "TestError", code: 456, userInfo: nil)))
                        }
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue({ task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect((error as NSError?)?.code).toEventually(equal(456), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(1), timeout: 0.6, pollInterval: 0.1)
                }
                
                it("expected to not call success block when error result") {
                    maybe = Maybe<NSNumber>.create(subscribe: { observer -> Disposable in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            observer(.error(NSError(domain: "TestError", code: 456, userInfo: nil)))
                        }
                        return Disposables.create()
                    })
                    
                    maybe.toBoltsTask().continue(successBlock: { task -> Any? in
                        error = task.error
                        result = task.result
                        
                        count += 1
                        return nil
                    })
                    
                    expect(error).toNotEventually(beNil(), timeout: 0.6, pollInterval: 0.1)
                    expect(result).toEventually(equal(NSNumber(value: -1)), timeout: 0.6, pollInterval: 0.1)
                    expect(count).toEventually(equal(0), timeout: 0.6, pollInterval: 0.1)
                }
            }
        }
    }
}
