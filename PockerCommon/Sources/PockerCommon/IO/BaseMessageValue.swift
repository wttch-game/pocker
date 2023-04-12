//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/14.
//

import Foundation

public protocol BaseMessageValue : Codable {
    associatedtype T : OpCode
    
    var opCode : T {
        get
    }
}

extension BaseMessageValue {
    public func toData() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
    
    public func toMessage() -> SocketMessage {
        return SocketMessage(opCode: self.opCode.opCode, subCode: self.opCode.subCode, value: toData())
    }
}
