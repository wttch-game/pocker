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
import CocoaLumberjackSwift


final class PockerHandler : ChannelInboundHandler {
    public typealias InboundIn = SocketMessage
    public typealias OutboundOut = SocketMessage
    
    func channelActive(context: ChannelHandlerContext) {
        guard let address = context.remoteAddress else { return }
        DDLogInfo("客户端已连接:\(address)")
        let socketMessage = SocketMessage(opCode: 1, subCode: 1, value: Data("你好，客户端:".utf8))
        context.channel.writeAndFlush(self.wrapOutboundOut(socketMessage)).whenComplete { result in
            DDLogDebug("发送成功.")
        }
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        if let address = context.remoteAddress {
            DDLogInfo("客户端已断开连接:\(address)")
        }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let msg = self.unwrapInboundIn(data)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        DDLogInfo("error:\(error)")
    }
}

extension PockerHandler : @unchecked Sendable {
    
}

enum PockerServerState : String {
    case notStart = "未启动"
    case pending = "启动中..."
    case fail = "启动失败!"
    case success = "已启动."
}


class PockerServer : ObservableObject {
    private let dispatchQueue = DispatchQueue(label: "socket", qos: .background)
    
    private var handler : PockerHandler
    private var group : MultiThreadedEventLoopGroup?
    private var bootstrap : ServerBootstrap?
    private var channel : Channel?
    
    
    @Published public var state : PockerServerState = .notStart
    
    // 监听的host和端口号
    private let host : String
    private let port : Int
    
    init() {
        host = "0.0.0.0"
        port = 18896
        self.handler = PockerHandler()
    }
    
    private func setState(_ state : PockerServerState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    func startBind() {
        dispatchQueue.async {
            self.syncBind()
        }
        DDLogInfo("start 已提交.")
    }
    
    func syncBind() {
        self.setState(.pending)
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        self.createBootstrap()
        self.bootstrapBind()
        defer {
            try! self.group?.syncShutdownGracefully()
        }
        do {
            try self.channel?.closeFuture.wait()
        } catch {
            DDLogInfo("channel close 失败!")
        }
        self.setState(.notStart)
        DDLogDebug("服务器已关闭!")
    }
    
    func shutdown() {
        try? channel?.close(mode: .all).wait()
        DDLogDebug("关闭服务器, 已提交.")
    }
    
    /// 创建nio引导
    private func createBootstrap() {
        self.bootstrap = ServerBootstrap(group: group!)
            .serverChannelOption(ChannelOptions.backlog, value: 100)
            // 允许套接字绑定到已在使用的地址
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer({ channel in
                channel.pipeline.addHandlers([
                    ByteToMessageHandler(SocketMessageDecoder()),
                    MessageToByteHandler(SocketMessageEncoder())
                ]).flatMap{ v in
                    channel.pipeline.addHandler(self.handler)
                }
            })
            // Enable SO_REUSEADDR for the accepted Channels
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
    
    /// 将引导绑定到指定端口
    private func bootstrapBind() {
        self.channel = try? self.bootstrap?.bind(host: host, port: port).wait()
        if channel == nil {
            DDLogError("绑定到[\(host):\(port)]失败!")
            self.setState(.fail)
        } else {
            DDLogInfo("服务器已启动并绑定到[\(host):\(port)].")
            self.setState(.success)
        }
    }
}
