//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/15.
//

import Foundation

public protocol OpCode {
    var opCode : Int {
        get
    }
    
    var subCode : Int {
        get
    }
}

public enum AccountCode : Int {
    // 注册请求
    case REGISTER_REQ = 0
    // 注册响应
    case REGISTER_RESP = 1
    
    // 登录请求
    case LOGIN_REQ = 2
    // 登录响应
    case LOGIN_RESP = 3
}

extension AccountCode : OpCode {
    public var opCode : Int {
        get { return 1 }
    }
    
    public var subCode : Int {
        get { return self.rawValue }
    }
}
