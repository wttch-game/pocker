//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/1.
//

import Foundation
import NIOCore


public class CodecUtil {
    public static func encodeMessage(_ msg: SocketMessage) -> ByteBuffer? {
        var buffer = ByteBuffer()
        buffer.writeInteger(msg.opCode)
        buffer.writeInteger(msg.subCode)
        buffer.writeInteger(msg.value.count)
        buffer.writeBytes(msg.value)
        return buffer
    }
    
    public static func decodeMessage(_ buff: inout ByteBuffer) -> SocketMessage {
        let opCode: Int = buff.readInteger()!
        let subCode: Int = buff.readInteger()!
        let length: Int = buff.readInteger()!
        let data: Data = Data(buff.readBytes(length: length)!)
        return SocketMessage(opCode: opCode, subCode: subCode, value: data)
    }
}
