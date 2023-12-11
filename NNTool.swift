//
//  NNTool.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/4/24.
//

import UIKit

public func topViewController() -> UIViewController{
    return topViewController(withRootViewController: UIApplication.shared.nn_keyWindow!.rootViewController!)
}

public func topViewController(withRootViewController rootViewController: UIViewController) -> UIViewController {
    if (rootViewController is UITabBarController) {
        let tabBarController = (rootViewController as! UITabBarController)
        guard let selectedViewController = tabBarController.selectedViewController else {
            return tabBarController
        }
        return topViewController(withRootViewController: selectedViewController)
    } else if (rootViewController is UINavigationController) {
        if rootViewController is NNNavigationController {
            let navigationController = (rootViewController as! NNNavigationController)
            return topViewController(withRootViewController: navigationController.visibleViewController!)
        } else {
            let navigationController = (rootViewController as! UINavigationController)
            return topViewController(withRootViewController: navigationController.visibleViewController!)
        }
    } else if (rootViewController.presentedViewController != nil) {
        let presentedViewController = rootViewController.presentedViewController
        return topViewController(withRootViewController: presentedViewController!)
    } else {
        return rootViewController
    }
}

