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


final class PockerHandler : ChannelInboundHandler {
    public typealias InboundIn = SocketMessage
    public typealias OutboundOut = SocketMessage
    
    func channelActive(context: ChannelHandlerContext) {
        guard let address = context.remoteAddress else { return }
        NSLog("客户端已连接:\(address)")
        let socketMessage = SocketMessage(opCode: 1, subCode: 1, value: Data("你好，客户端:".utf8))
        context.channel.writeAndFlush(self.wrapOutboundOut(socketMessage)).whenComplete { result in
            NSLog("发送成功.")
        }
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        if let address = context.remoteAddress {
            NSLog("客户端已断开连接:\(address)")
        }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let msg = self.unwrapInboundIn(data)
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
                channel.pipeline.addHandlers([
                    ByteToMessageHandler(SocketMessageDecoder()),
                    MessageToByteHandler(SocketMessageEncoder())
                ]).flatMap{ v in
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
