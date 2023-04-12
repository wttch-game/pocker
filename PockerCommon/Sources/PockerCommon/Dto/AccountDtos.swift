//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/14.
//

import Foundation

// 登录请求
public class LoginRequestDto : BaseMessageValue {
    public typealias T = AccountCode
    // 用户名
    public let username : String
    // TODO: sha256 密码
    public let password : String
    
    public var opCode : AccountCode { get { return .REGISTER_REQ } }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

// 登录响应
public class LoginResponseDto : BaseMessageValue {
    public typealias T = AccountCode
    
    public let code : Int
    public let message : String
    
    public var opCode: AccountCode { get { return .REGISTER_RESP } }
    
    public init(code : Int, message : String) {
        self.code = code
        self.message = message
    }
}
