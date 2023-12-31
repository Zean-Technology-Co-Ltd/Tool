//
//  Storage.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Foundation

struct Storage {

    struct User: StringDefaultSettable, BoolDefaultSettable, IntegerDefaultSettable {
        
        enum StringKey: String {
            case lastLoginUserName
        }

        enum BoolKey: String {
            case firstLoginConfig
        }
        
        enum IntegerKey: String {
            case authenticationStatus
        }
    }
    
    struct APP: StringDefaultSettable, BoolDefaultSettable, IntegerDefaultSettable {
        
        enum StringKey: String {
            case appStroreAppVersion
        }

        enum BoolKey: String {
            case firstLoginConfig
        }
        
        enum IntegerKey: String {
            case authenticationStatus
        }
    }
    
    struct Coordinate: StringDefaultSettable {
        enum StringKey: String {
            case latitude
            case longitude
        }
    }
    
    struct Authorization: DataDefaultSettable {
        enum DataKey: String {
            case token
            case user
            case oauthUser
        }
    }
    
    struct HaveOrder: BoolDefaultSettable {
        enum BoolKey: RawRepresentable {
            init?(rawValue: String) {
                return nil
            }
            
            typealias RawValue = String
            
            case haveOrder(key: String)
            
            public var rawValue: RawValue {
                switch self {
                case let .haveOrder(key):
                    return key
                }
            }
        }
    }
    
    struct ZMScoreImage: StringDefaultSettable {
        enum StringKey: RawRepresentable {
            init?(rawValue: String) {
                return nil
            }
            
            typealias RawValue = String
            
            case zmScoreImage(key: String?)
            
            public var rawValue: RawValue {
                switch self {
                case let .zmScoreImage(key):
                    return "\(key ?? "")-zmScoreImage"
                }
            }
        }
    }
    
    struct SaveBaseData: DataDefaultSettable {
        enum DataKey: RawRepresentable {
            case saveBaseData(ofUserId: String)
            
            typealias RawValue = String
            
            init?(rawValue: RawValue) {
                return nil
            }
            
            public var rawValue: RawValue {
                switch self {
                case let .saveBaseData(ofUserId):
                    return "\(ofUserId)-UserID"
                }
            }
        }
    }

//    struct Building: StringArrayDefaultSettable, DataDefaultSettable {
//
//        enum StringArrayKey: RawRepresentable {
//            case selectedBuildingIDs(ofUserId: Int)
//
//            typealias RawValue = String
//
//            init?(rawValue: RawValue) {
//                return nil
//            }
//
//            public var rawValue: RawValue {
//                switch self {
//                case let .selectedBuildingIDs(ofUserId):
//                    return "\(ofUserId)-selectedBuildingIDs"
//                }
//            }
//        }
//
//        enum DataKey: RawRepresentable {
//            case buildingPortfolioSelection(ofUserId: Int)
//
//            typealias RawValue = String
//
//            init?(rawValue: RawValue) {
//                return nil
//            }
//
//            public var rawValue: RawValue {
//                switch self {
//                case let .buildingPortfolioSelection(ofUserId):
//                    return "\(ofUserId)-buildingPortfolioSelection"
//                }
//            }
//        }
//
//    }
//
    

//
//    struct APPVersion: StringDefaultSettable {
//
//        enum StringKey: String {
//            case appVersion
//        }
//    }
//
//    struct Flag: BoolDefaultSettable {
//
//        enum BoolKey: String {
//            case responseLoggerSwitch
//        }
//    }
//
//    struct Theme: StringDefaultSettable {
//
//        enum StringKey: String {
//            case customLoginIcon
//        }
//    }
//
//    struct RoomPromotion: BoolDefaultSettable {
//        enum BoolKey: String {
//            case canRoomPromotion
//        }
//    }
}
