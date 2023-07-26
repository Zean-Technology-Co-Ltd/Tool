//
//  DebugTools.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import UIKit

#if DEBUG
struct DebugTools {
    
    static func show(_ nav: UIViewController) {
        
        let alertController = UIAlertController(title: "开发选项", message: "", preferredStyle: .actionSheet)
        
        let changeURLAction = UIAlertAction(title: "切换服务器地址", style: .default) { (_) in
            
            let alertController = UIAlertController(title: "选择地址", message: "当前地址:\(NNApiConst.APIKey.serverURL)", preferredStyle: .alert)
            let ensureAction = UIAlertAction(title: "确定", style: .default, handler: { [weak alertController] (_) in
                guard let address = alertController?.textFields?.first?.text else {
                    return
                }
                changeServerAddress(address)
                
            })
            let betaAction = UIAlertAction(title: "测试环境:\(NNApiConst.APIKey.rcURL)", style: .default, handler: { (_) in
                changeServerAddress(NNApiConst.APIKey.rcURL)
            })
//            let stagingAction = UIAlertAction(title: "预发环境:\(NNApiConst.APIKey.stagingURL)", style: .default, handler: { (_) in
//                changeServerAddress(NNApiConst.APIKey.stagingURL)
//                changeAccount(NNApiConst.APIKey.accountStagingURL)
//                changeWebAddress(NNApiConst.APIKey.webStagingURL)
//            })
            let releaseAction = UIAlertAction(title: "正式环境:\(NNApiConst.APIKey.appstoreURL)", style: .default, handler: { (_) in
                changeServerAddress(NNApiConst.APIKey.appstoreURL)
            })
            
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "ex: http://10.0.0.1/app/"
                textField.returnKeyType = .done
                textField.text = "https://"
            })
            
            alertController.addActionsWithCancel(actions: [ensureAction, betaAction, releaseAction])
            nav.present(alertController, animated: true, completion: nil)
        }
        
        var actions = [changeURLAction]

        
        alertController.addActionsWithCancel(actions: actions)
        
        nav.present(alertController, animated: true, completion: nil)
    }
    
    static func changeServerAddress(_ address: String) {
        NNApiConst.APIKey.serverURL = address
        NNNavigationManager.sharedInstance.switchRoot(.loginOut)
        exit(0)
    }
}
#endif
