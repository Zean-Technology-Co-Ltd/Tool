//
//  ActivityIndicatorPlugin.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Moya
import Result

public struct ActivityIndicatorPlugin: PluginType {
    
    static let `defult` = ActivityIndicatorPlugin()
    
    /// Called immediately before a request is sent over the network (or stubbed).
    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
}
