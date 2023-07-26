//
//  StatusCodeResponse.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/20.
//

import UIKit

public struct StatusCodeResponse: Codable {

    let code: String
    let msg: String
    var isSucess: Bool {
        return code == "00000"
    }
}
