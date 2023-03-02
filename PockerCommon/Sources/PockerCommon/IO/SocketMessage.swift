//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/1.
//

import Foundation
import NIO

public struct SocketMessage {
    public let opCode: Int
    public let subCode: Int
    public let value: Data
    
    public init(opCode: Int, subCode: Int, value: Data) {
        self.opCode = opCode
        self.subCode = subCode
        self.value = value
    }
}

public class SocketMessageEncoder : MessageToByteEncoder {
    public typealias OutboundIn = SocketMessage
    
    public init() {}
    
    public func encode(data: SocketMessage, out: inout ByteBuffer) throws {
        var msgData = CodecUtil.encodeMessage(data)!
        out.writeInteger(msgData.readableBytes)
        out.writeBuffer(&msgData)
    }
}

public class SocketMessageDecoder : ByteToMessageDecoder {
    public typealias InboundOut = SocketMessage
    
    public init() {}
    
    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard buffer.readableBytes >= 4 else { return .continue }
        let length: Int = buffer.readInteger()!
        NSLog("data length : \(length)")
        if buffer.readableBytes < length {
            return .needMoreData
        }
        context.fireChannelRead(self.wrapInboundOut(CodecUtil.decodeMessage(&buffer)))
        return .continue
    }
}
