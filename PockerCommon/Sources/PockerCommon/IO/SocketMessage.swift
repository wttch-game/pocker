//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/1.
//

import Foundation

/// 所有网络通信都要包装成这个类
public struct SocketMessage {
    // 操作码
    public let opCode: Int
    // 子操作码
    public let subCode: Int
    // 附加数据
    public let value: Data
    
    public init(opCode: Int, subCode: Int, value: Data) {
        self.opCode = opCode
        self.subCode = subCode
        self.value = value
    }
}
