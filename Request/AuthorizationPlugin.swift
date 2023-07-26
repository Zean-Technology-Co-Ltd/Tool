//
//  AuthorizationPlugin.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Foundation
import Result
import Moya
import RxSwift

public typealias RequestResponse = Moya.Response

public protocol AccessTokenAuthorizable {
    var shouldAuthorize: Bool { get }
    var tokenExpiredToLogin: Bool { get }
}

public protocol RequestAuthorizationPluginStaticFetchable {
    var authorizationPlugin: RequestAuthorizationPlugin { get }
}

protocol RequestAuthorizationPluginUpdate {
    func updatePlugin(token: String?)
}

/// 外部处理认证失败的协议
protocol RequestUnAuthorisedProcess: NSObjectProtocol {
    func register(unAuthorisedProcessor: RequestUnAuthorisedProcess)
    func processUnAuthorisedResponse(_ response: RequestResponse?, message: String?) -> Result<Moya.Response, MoyaError>?
}

extension AccessTokenAuthorizable {
    var tokenExpiredToLogin: Bool {
        return true
    }
}

/// 提供默认实现方法
extension RequestAuthorizationPluginStaticFetchable {
    public var authorizationPlugin: RequestAuthorizationPlugin {
        return RequestAuthorizationPlugin.default
    }
}

extension RequestAuthorizationPluginUpdate {
    func updatePlugin(token: String?) {
        if let token = token {
            RequestAuthorizationPlugin.default.token = tokenPrefix + token
        } else {
            RequestAuthorizationPlugin.default.token = nil
        }
    }
}

extension RequestUnAuthorisedProcess {
    
    func register(unAuthorisedProcessor: RequestUnAuthorisedProcess) {
        RequestAuthorizationPlugin.default.unAuthorisedProcesser = unAuthorisedProcessor
    }
}

/// 负责http的验证以及处理http无权限的问题（Authorization过期或非法）
public final class RequestAuthorizationPlugin: PluginType, RequestAuthorizationPluginUpdate, AuthorizationAccessible, AccessTokenUpdate {
    
    static let `default` = RequestAuthorizationPlugin()
    
    weak var unAuthorisedProcesser: RequestUnAuthorisedProcess?
    var token: String?
    var refreshAction: Observable<TokenResponseModel?>?
    var authProvider: Request<AuthenticationAPI>?
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let authorizable = target as? AccessTokenAuthorizable,
           authorizable.shouldAuthorize == true {
            if let authVal = token {
                request.addValue(authVal, forHTTPHeaderField: "Authorization")
            } else if let authVal = Authorization.default.accessToken{
                request.addValue(tokenPrefix + authVal, forHTTPHeaderField: "Authorization")
            }
        }
        request.addValue("iOS", forHTTPHeaderField: "clientType")
        return request
    }
    
    public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        
        if case .failure(let error) = result {
            if case let .underlying(error, response) = error {
                if let requestError = error as? RequestError {
                    
                    switch requestError {
                    case .statusCode(let statusCode, (let error, _)):
                        guard statusCode == 401, let processer = unAuthorisedProcesser else { return result }
                        // 正常只有 refresh-token 过期, 更新 token 失败时才会进入
                        if let authorizable = target as? AccessTokenAuthorizable,
                           authorizable.tokenExpiredToLogin == true,
                           let _result = processer.processUnAuthorisedResponse(response, message: error){
                            log.info(authorizable.shouldAuthorize)
                            return _result
                        }
                    default:
                        break
                    }
                }
            }
        }
        return result
    }
    
    func refreshWrap<T>(_ ob: Observable<T>) -> Observable<T> {
        if (isAccessTokenExpirated && !isRefreshTokenExpirated) {
            setNeedsRefresh()
        }
        if let refreshAction = refreshAction {
            let wrapped = refreshAction.concatMap { _ in ob }
            return wrapped
        } else {
            return ob
        }
    }
    
    private func setNeedsRefresh() {
        if (self.refreshAction == nil) {
            self.authProvider = Request<AuthenticationAPI>()
            self.refreshAction = self.authProvider!.rxRequesOneResponse(target: .refreshLogin(token: self.refreshToken ?? ""), mapType: TokenResponseModel.self)
                .map { result -> TokenResponseModel? in
                    switch result {
                    case .success(let token):
                        return token
                    case .failure(let error):
                        Toast.showError(error.message)
                        return nil
                    }
                }
                .do(onNext: { tokenModel in
                    if let tokenModel = tokenModel {
                        self.updatePlugin(token: tokenModel.access_token)
                        self.updateAuthorizedWrapper(AuthorizedWrapper(token: tokenModel, user: Authorization.default.user))
                    }
                },
                    onCompleted: { [weak self] in
                    self?.refreshAction = nil
                })
                .share()
                .observe(on: MainScheduler.asyncInstance)
        }
    }
}

let tokenPrefix: String = "Bearer "
