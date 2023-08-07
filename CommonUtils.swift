//
//  CommonUtils.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/8/4.
//

import UIKit

enum CurrentCarrier: String {
    case chinaMobile = "中国移动"
    case chinaUnicom = "中国联通"
    case chinaTelecom = "中国电信"
    case unkonw = "未知"
}
class CommonUtils: NSObject {
    ///判断移动
    static public func isChinaMobile(_ moblie: String) -> Bool{
        let CM = "(^134[0-8]\\d{7}$)|(^1(3[5-9]|4[7]|5[0-27-9]|6[5]|7[28]|8[2-478]|9[8])\\d{8}$)|(^170[356]\\d{7})"
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
        return regextestcm.evaluate(with: moblie)
    }
    
    ///判断联通
    static public func isChinaUnicom(_ moblie: String) -> Bool{
        let CU = "(^1(3[0-2]|4[5]|5[56]|6[67]|7[156]|8[56])\\d{8}$)|(^170[47-9]\\d{7}$)"
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CU)
        return regextestcm.evaluate(with: moblie)
    }
    
    ///判断电信
    static public func isChinaTelecom(_ moblie: String) -> Bool{
        let CT = "(^1(3[3]|4[9]|5[3]|6[2]|7[37]|8[019]|9[19])\\d{8}$)|(^170[0-2]\\d{7}$)"
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CT)
        return regextestcm.evaluate(with: moblie)
    }
    
    ///判断运营商
    static public func currentCarrierType(_ moblie: String) -> CurrentCarrier{
        return isChinaMobile(moblie) ? .chinaMobile: (isChinaUnicom(moblie) ? .chinaUnicom: (isChinaTelecom(moblie) ? .chinaTelecom: .unkonw))
    }
}
