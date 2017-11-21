# RxToBolts

Objective-C [Bolts](https://github.com/BoltsFramework/Bolts-ObjC) wrapper for [RxSwift](https://github.com/ReactiveX/RxSwift) one time event traits

[![Build Status](https://travis-ci.org/junmo-kim/RxToBolts.svg?branch=master)](https://travis-ci.org/junmo-kim/RxToBolts)

If you want to introduce RxSwift but hesitated from tons of legacy Objective-C classes, this can help.

## Get started

1. In Podfile add this and install
```
pod 'RxToBolts'
```

2. Write your Rx code in Swift
```swift
@objc class Service {
    func getStatus() -> Single<Status> {
        return Single<Status>.create { observer -> Disposable in
            [...]
        }
    }
}
```

3. Add wrapper method without any efforts
```swift
extension Service {
    @objc func objc_getStatus() -> BFTask<Status> {
        return getStatus().toBoltsTask()
    }
}
```

4. Use it on Objective-C
```objective-c
- (void)didTapLoadStatus {
    [[Service objc_getStatus] continueWithBlock:^id(BFTask *task) {
        if (task.isCancelled) {
            // get status was cancelled.
        } else if (task.error) {
            // get status failed.
        } else {
            Status *status = task.result;
            NSLog(@"Status: %@", status.text);
        }
        return nil;
    }];
}
```

:tada:
