//
//  File.swift
//  
//
//  Created by Wttch on 2023/3/1.
//

import Foundation
import NIO
import CocoaLumberjackSwift

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


extension SocketMessage {
    
    /// 将网络消息转换为 ByteBuffer 对象.
    /// 按以下顺序写入 buffer 对象中: 操作码、子操作码、附加数据长度、附加数据
    /// - Returns: 转换成的 ByteBuffer 对象
    public func toBuffer() -> ByteBuffer {
        var buffer = ByteBuffer()
        buffer.writeInteger(opCode)
        buffer.writeInteger(subCode)
        buffer.writeInteger(value.count)
        buffer.writeBytes(value)
        return buffer
    }
}

extension ByteBuffer {
    /// 从 ByteBuffer 缓冲中读取网络消息.
    /// 按操作码、子操作码、附加数据长度、附加数据顺序读取数据.
    /// - Returns: 读取到的网络消息, 如果组装失败则返回 nil
    public mutating func readSocketMessage() -> SocketMessage? {
        if let opCode: Int = readInteger(), let subCode: Int = readInteger(), let length: Int = readInteger() {
            if let data: [UInt8] = readBytes(length: length) {
                return SocketMessage(opCode: opCode, subCode: subCode, value: Data(data))
            }
        }
        return nil
    }
}

/// 网络消息编码器
public class SocketMessageEncoder : MessageToByteEncoder {
    public typealias OutboundIn = SocketMessage
    
    public init() {}
    
    /// 编码网络消息对象.
    /// 将网络消息转换为 ByteBuffer 对象, 先将数据长度送入编码器, 然后再送入数据的 ByteBuffer 对象.
    /// - Parameters:
    ///   - data: 要编码的网络消息对象
    ///   - out: 要编码进的 `ByteBuffer`
    public func encode(data: SocketMessage, out: inout ByteBuffer) throws {
        let msgData = data.toBuffer()
        out.writeInteger(msgData.readableBytes)
        out.writeImmutableBuffer(msgData)
    }
}

// 网络消息解码器
public class SocketMessageDecoder : ByteToMessageDecoder {
    public typealias InboundOut = SocketMessage
    
    public init() {}
    
    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard buffer.readableBytes >= 4 else { return .continue }
        let length: Int = buffer.readInteger()!
        DDLogDebug("data length : \(length)")
        if buffer.readableBytes < length {
            return .needMoreData
        }
        context.fireChannelRead(self.wrapInboundOut(CodecUtil.decodeMessage(&buffer)))
        return .continue
    }
}
