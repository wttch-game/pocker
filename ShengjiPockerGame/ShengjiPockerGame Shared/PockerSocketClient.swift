//
//  PockerSocketClient.swift
//  PockerGame
//
//  Created by Wttch on 2023/3/2.
//

import Foundation
import NIOCore
import NIOPosix
import PockerCommon
import CocoaLumberjackSwift

class PockerClientHandler : ChannelInboundHandler {
    public typealias InboundIn = SocketMessage
    
    func channelActive(context: ChannelHandlerContext) {
        
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        NSLog("read: \(String(data: self.unwrapInboundIn(data).value, encoding: .utf8))")
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        
    }
    
    
}

class PockerSocketClient {
    let group : MultiThreadedEventLoopGroup
    let bootstrap : ClientBootstrap
    let handler : PockerClientHandler
    var channel : Channel?
    
    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let handler = PockerClientHandler()
        bootstrap = ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer({ channel in
                channel.pipeline.addHandlers([
                    ByteToMessageHandler(SocketMessageDecoder()),
                    MessageToByteHandler(SocketMessageEncoder())
                ]).flatMap{ v in
                    channel.pipeline.addHandler(handler)
                }
            })
        self.handler = handler
    }
    
    func connect() {
        let host = "0.0.0.0"
        let port = 18896
        do {
            channel = try bootstrap.connect(host: host, port: port).wait()
        } catch {
            NSLog("\(error)")
        }
    }
    
    func sendMessage(_ msg : SocketMessage) {
        NSLog("客户端发送消息:\(msg)")
        channel?.writeAndFlush(msg)
    }
}
