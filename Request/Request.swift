//
//  Request.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Moya
import Result
import RxSwift

public enum RequestCachePolicy {
    case none
    case time(Int)
}

public protocol RequestTargetType: TargetType, AccessTokenAuthorizable {
    var parameters: [String: Any]? { get }
    var cachePolicy: RequestCachePolicy { get }
}

public typealias ResultWrapper<T> = Result<T, RequestError>
public typealias ResultStream<T> = Observable<ResultWrapper<T>>


final class Request<Target: RequestTargetType>: MoyaProvider<Target> {
    
    public init(plugins: [PluginType] = []) {
        let plugin = Plugin()
        var extenPlugins: [PluginType] = [plugin.errorPlugin, plugin.authorizationPlugin, plugin.indicatorPlugin, ]
        #if DEBUG
        extenPlugins.append(contentsOf: [LoggingPlugin.shared])
        #endif
        super.init(manager: sessionManager, plugins: extenPlugins, trackInflights: false)
    }
    
    deinit {
        log.debug(self)
    }
}

extension Request: ReactiveCompatible {
    
}

public extension Reactive where Base: MoyaProviderType {
    
    fileprivate func refreshWrap<T>(_ ob: Observable<T>) -> Observable<T> {
//        return RequestAuthorizationPlugin.default.refreshWrap(ob)
        return ob
    }
    
    func request(objectTarget: Base.Target) -> Observable<Result<Moya.Response, RequestError>> {
        return refreshWrap(base.rxRequesOneResponse(target: objectTarget))
    }
    
    func request<T: Codable>(objectTarget: Base.Target, mapType: T.Type) -> Observable<Result<T, RequestError>> {
        return refreshWrap(base.rxRequesOneResponse(target: objectTarget, mapType: mapType))
    }
    
    func request<T: Codable>(listTarget: Base.Target, mapType: T.Type) -> Observable<Result<[T], RequestError>> {
        return refreshWrap(base.rxRequestListResponse(listTarget, mapType: mapType))
    }
    
//    func uploadImages<T: Codable>(images: [UIImage]) -> Observable<Result<[T], RequestError>> {
//        return refreshWrap(base.rxUploadImagesResponse(images))
//    }
}

extension MoyaProviderType {
    func rxRequesOneResponse(target: Target) -> Observable<Result<Moya.Response, RequestError>> {
        return Observable.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let cancellableToken = self.request(target, callbackQueue: DispatchQueue.main, progress: nil) { result in
                switch result {
                case let .success(response):
                    observer.onNext(Result.success(response))
                    observer.onCompleted()
                case let .failure(error):
                    if case let .underlying( _error, _) = error {
                        observer.onNext(Result.failure(_error as! RequestError))
                        observer.onCompleted()
                    }
                    else if case let .requestMapping(message) = error {
                        observer.onNext(Result.failure(RequestError.requestMapping(message)))
                        observer.onCompleted()
                    }
                    else {
                        observer.onNext(Result.failure(RequestError.unkonwn))
                        observer.onCompleted()
                    }
                }
            }
            
            CancelRequest.shared.add(cancellableToken)
            
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
    
    func rxRequesOneResponse<T: Codable>(target: Target, mapType: T.Type) -> Observable<Result<T, RequestError>> {
        return Observable.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let cancellableToken = self.request(target, callbackQueue: DispatchQueue.main, progress: nil) { result in
                switch result {
                case let .success(response):
                        do {
#if DEBUG
                            let json = try response.mapJSON()
                            log.info(response.request?.url as Any)
                            log.info(json)
                            //强制解包会报出具体解包错误原因，方便调试
                            let _: T = try! JSONDecoder().decode(T.self, from: response.data)
#endif
                            let data: T = try JSONDecoder().decode(T.self, from: response.data)
                            let statusCode = validateResponseState(response: response)
                            if statusCode.isSucess {
                                observer.onNext(Result.success(data))
                            } else {
                                observer.onNext(Result.failure(RequestError.stringMapping(statusCode.msg)))
                            }
                            observer.onCompleted()
                            
                        } catch {
                            observer.onNext(Result.failure(RequestError.jsonMapping(error.localizedDescription)))
                            observer.onCompleted()
                        }
                case let .failure(error):
                    if case let .underlying( _error, _) = error {
                        observer.onNext(Result.failure(_error as! RequestError))
                        observer.onCompleted()
                    }
                    else if case let .requestMapping(message) = error {
                        observer.onNext(Result.failure(RequestError.requestMapping(message)))
                        observer.onCompleted()
                    }
                    else {
                        observer.onNext(Result.failure(RequestError.unkonwn))
                        observer.onCompleted()
                    }
                }
            }
            
            CancelRequest.shared.add(cancellableToken)
            
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
    
    func rxRequestListResponse<T: Codable>(_ target: Target, mapType: T.Type) -> Observable<Result<[T], RequestError>> {
        
        return Observable.create { [weak self] observer in
            
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let cancellableToken = self.request(target, callbackQueue: DispatchQueue.main, progress: nil) { result in
                switch result {
                case let .success(response):
                    
                    do {
                        #if DEBUG
                        let json = try response.mapJSON()
                        log.info(response.request!.url as Any)
                        log.info(json)
                        //强制解包会报出具体解包错误原因，方便调试
                        let _: T = try! JSONDecoder().decode(T.self, from: response.data)
                        #endif
                        let data: [T] = try JSONDecoder().decode([T].self, from: response.data)
                        observer.onNext(.success(data))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(Result.failure(RequestError.jsonMapping(error.localizedDescription)))
                        observer.onCompleted()
                    }
                case let .failure(error):
                    if case let .underlying( _error, _) = error {
                        observer.onNext(Result.failure(_error as! RequestError))
                        observer.onCompleted()
                    }
                    else if case let .requestMapping(message) = error {
                        observer.onNext(Result.failure(RequestError.requestMapping(message)))
                        observer.onCompleted()
                    }
                    else {
                        observer.onNext(Result.failure(RequestError.unkonwn))
                        observer.onCompleted()
                    }
                }
            }
            
            CancelRequest.shared.add(cancellableToken)
            
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
}

private func validateResponseState(response: Moya.Response) -> StatusCodeResponse{
    do {
        let statusCode: StatusCodeResponse = try JSONDecoder().decode(StatusCodeResponse.self, from: response.data)
    //        if response.request?.httpMethod == "POST" {
    //            return SJNetworkManager.sharedNormalData().lw_getRequestSuccessStatusData(with: path, statusCode: statusCode, status: status, result: json)
    //        } else {
        return statusCode
    //        }
    } catch {
        return StatusCodeResponse(code: "00000", msg: "")
    }
    
}

private let sessionManager: Manager = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
    
    let manager = Manager(configuration: configuration)
    manager.startRequestsImmediately = false
    return manager
}()

private struct Plugin: RequestErrorPluginStaticFetchable, RequestAuthorizationPluginStaticFetchable, ActivityIndicatorPluginStaticFetchable { }


public class CancelRequest {
    
    private let cancellables = NSHashTable<AnyObject>.weakObjects()
    
    static let shared = CancelRequest()
    
    private init() {  }
    
    func add(_ cancel: Cancellable) {
        cancellables.add(cancel as AnyObject)
    }
    
    func cancelAll() {
        (self.cancellables.allObjects as! [Cancellable]).forEach { $0.cancel() }
    }
}
