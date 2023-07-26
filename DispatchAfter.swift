//
//  DispatchAfter.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/4/25.
//

import Foundation

typealias DelayTask = (_ cancel: Bool) -> Void

@discardableResult
func delay(time: TimeInterval, task:@escaping () -> Void) -> DelayTask? {

    func dispatchLater(block: @escaping () -> Void) {
        let deadlineTime = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: block)
    }

    var closure: (() -> Void)? = task
    var result: DelayTask?

    let delayedClosure: DelayTask = { cancel in
        if let _closure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: _closure)
            }
        }
        closure = nil
        result = nil
    }

    result = delayedClosure

    dispatchLater {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }

    return result
}

func cancel(task: DelayTask?) {
    task?(true)
}
