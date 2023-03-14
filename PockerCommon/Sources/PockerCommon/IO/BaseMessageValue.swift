//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/14.
//

import Foundation

public protocol BaseMessageValue : Codable {
    var opCode : Int {
        get
    }
    
    var subCode : Int {
        get
    }
}

extension BaseMessageValue {
    public func toData() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
    
    public func toMessage() -> SocketMessage {
        return SocketMessage(opCode: self.opCode, subCode: self.subCode, value: toData())
    }
}
