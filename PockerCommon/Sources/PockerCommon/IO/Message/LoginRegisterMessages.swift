//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/14.
//

import Foundation

public struct LoginMessageValue : BaseMessageValue {
    public let username : String
    
    // TODO: sha256 密码
    public let password : String
    
    public var opCode: Int = 1
    public var subCode: Int = 2
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    enum Keys : CodingKey {
        case username
        case password
    }
}
