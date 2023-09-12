//
//  Authorization.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/4/25.
//

import UIKit

/// 登录信息更新协议

protocol AccessTokenUpdate {
    
    func updateAuthorizedWrapper(_ wrapper: AuthorizedWrapper?)
    
    func updateUser(_ user: User?)
    
    func updateOauthUser(_ oauthUser: OauthUser?)
    
    func deleteAuthorizedWrapper()
}

/// 本地登录信息获取协议
/*
 1. 登录状态，保存有未过期的RefreshToken即视为登录状态
 3. RefreshToken过期，引导用户重新登录
 */
protocol AuthorizationAccessible {
    
    var isLoggedIn: Bool { get } // To User Login
    
    var isAccessTokenExpirated: Bool { get }
    
    var isRefreshTokenExpirated: Bool { get }
    
    var refreshToken: String? { get }
    
    var accessToken: String? { get }
}

/// 本地用户信息获取协议
protocol UserInformationAccessible {
    
    var userName: String? { get }
    
    var userID: Int? { get }
    
    var tel: String? { get }
    
    var wechat: String? { get }
    
    var customerId: Int? { get }
    
    func updateWechat(_ wechat: String)
    func updateName(_ name: String)
    func updateTel(_ tel: String)
}

extension AccessTokenUpdate {
    
    func updateAuthorizedWrapper(_ wrapper: AuthorizedWrapper?) {
        if let wrapper = wrapper {
            Authorization.default.wrapper = wrapper
            if let token = wrapper.token {
                Storage.Authorization.set(token.toJSONData(), forKey: .token)
            }
            if let user = wrapper.user {
                Storage.Authorization.set(user.toJSONData(), forKey: .user)
            }
            
            if let oauthUser = wrapper.oauthUser {
                Storage.Authorization.set(oauthUser.toJSONData(), forKey: .oauthUser)
            }
        }
    }
    
    func updateUser(_ user: User?) {
        if let user = user {
            Storage.Authorization.set(user.toJSONData(), forKey: .user)
            Authorization.default.user = user
        }
    }
    
    func updateOauthUser(_ oauthUser: OauthUser?) {
        if let oauthUser = oauthUser {
            Storage.Authorization.set(oauthUser.toJSONData(), forKey: .oauthUser)
            Authorization.default.oauthUser = oauthUser
            if oauthUser.applyState == 4 {
                TrackManager.default.setBaseMsg()
            }
        }
    }
    
    func deleteAuthorizedWrapper() {
        Authorization.default.wrapper = nil
        Storage.Authorization.set(nil, forKey: .token)
        Storage.Authorization.set(nil, forKey: .user)
        Storage.Authorization.set(nil, forKey: .oauthUser)
        Storage.SaveBaseData.set(nil, forKey: .saveBaseData(ofUserId: "\(Authorization.default.token?.username ?? "0")"))
    }
}

extension AuthorizationAccessible {
    
    var isLoggedIn: Bool {
        return !isAccessTokenExpirated
    }
    
    var isAccessTokenExpirated: Bool {
        guard let expirationDate = Authorization.default.accessTokenExpDate else {
            return true
        }
        return expirationDate <= Date()
    }
    
    var isRefreshTokenExpirated: Bool {
        guard let expirationDate = Authorization.default.refreshTokenExpDate else {
            return true
        }
        return expirationDate <= Date()
    }
    
    var refreshToken: String? {
        return Authorization.default.wrapper?.token?.refresh_token
    }
    
    var accessToken: String? {
        return Authorization.default.wrapper?.token?.access_token
    }
}

extension UserInformationAccessible {
    
    var userName: String? {
        return Authorization.default.user?.nickName
    }

    var userID: String? {
        return Authorization.default.user?.id
    }

    var tel: String? {
        return Authorization.default.user?.mobile
    }
}

public final class Authorization: NSObject {
    
    static let `default`: Authorization = {
        var authorization = Authorization()
        
        var token: TokenResponseModel? {
            return Storage.Authorization.decodedData(forKey: .token)
        }
        
        var oauthUser: OauthUser? {
            return Storage.Authorization.decodedData(forKey: .oauthUser)
        }
        
        var user: User? {
            return Storage.Authorization.decodedData(forKey: .user)
        }
        
        authorization.wrapper = AuthorizedWrapper(token: token, user: user, oauthUser: oauthUser)
        return authorization
    }()
    
    var user: User?
    var token: TokenResponseModel?
    var oauthUser: OauthUser?
    var accessToken: String?
    var accessTokenExpDate: Date?
    var refreshTokenExpDate: Date?
    
    var wrapper: AuthorizedWrapper? {
        didSet {
            update(wrapper: wrapper)
        }
    }
    
    private func update(wrapper: AuthorizedWrapper?) {
        if let timeInterval =  wrapper?.token?.expires_in {
            refreshTokenExpDate = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        } else {
            refreshTokenExpDate = nil
        }
        
        if let accessToken = wrapper?.token?.access_token  {
            if let timeInterval =  wrapper?.token?.expires_in {
                accessTokenExpDate = Date(timeIntervalSince1970: TimeInterval(timeInterval))
            }
            self.user = wrapper?.user
            self.token = wrapper?.token
            self.oauthUser = wrapper?.oauthUser
            self.accessToken = accessToken
        } else {
            self.user = nil
            self.token = nil
            self.oauthUser = nil
            self.accessToken = nil
        }
    }
}
