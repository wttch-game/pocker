//
//  PockerServer.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/1.
//

import Foundation
import NIOCore
import NIOPosix
import PockerCommon

final class PockerMessageCodec : ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = ByteBuffer
    
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        let readable = buffer.withUnsafeReadableBytes { $0.firstIndex(of: "\n".utf8.first!) }
        if let r = readable {
            context.fireChannelRead(self.wrapInboundOut(buffer.readSlice(length: r + 1)!))
            return .continue
        }
        return .needMoreData
    }
}


final class PockerHandler : ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
    func channelActive(context: ChannelHandlerContext) {
        guard let address = context.remoteAddress else { return }
        NSLog("客户端已连接:\(address)")
        // context.write(.init(1)).wait()
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        if let address = context.remoteAddress {
            NSLog("客户端已断开连接:\(address)")
        }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        NSLog("error:\(error)")
    }
}

extension PockerHandler : @unchecked Sendable {
    
}

enum PockerServerState : String {
    case pending = "启动中..."
    case fail = "启动失败!"
    case success = "已启动."
}


class PockerServer {
    private let handler : PockerHandler
    private let group : MultiThreadedEventLoopGroup
    private let bootstrap : ServerBootstrap
    
    init() {
        let handler = PockerHandler()
        self.handler = handler
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        self.group = group
        bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 100)
            // 允许套接字绑定到已在使用的地址
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer({ channel in
                channel.pipeline.addHandler(ByteToMessageHandler(PockerMessageCodec())).flatMap{ v in
                    channel.pipeline.addHandler(handler)
                }
            })
            // Enable SO_REUSEADDR for the accepted Channels
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

    }
    
    func setState(_ state : PockerServerState, _ action : (PockerServerState) -> Void) {
        action(state)
    }
    
    func bind( _ action : (PockerServerState) -> Void) {
        setState(.pending, action)
        let host = "0.0.0.0"
        let port = 18896
        guard let channel = try? bootstrap.bind(host: host, port: port).wait() else {
            NSLog("绑定到[\(host):\(port)]失败!")
            setState(.fail, action)
            return
        }
        defer {
            try! group.syncShutdownGracefully()
        }
        NSLog("服务器已启动并绑定到[\(host):\(port)].")
        setState(.success, action)
        do {
            try channel.closeFuture.wait()
        } catch {
            NSLog("channel close 失败!")
        }
        NSLog("服务器已关闭!")
    }
}
