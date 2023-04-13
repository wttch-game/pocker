//
//  File.swift
//  
//
//  Created by Wttch on 2023/4/8.
//

import Foundation
import Network


open class SocketServer {
    let port : NWEndpoint.Port
    var listener : NWListener? = nil
    
    private var connectionsByID: [Int: ServerConnection] = [:]
    
    private var listenerQueue : DispatchQueue = DispatchQueue(label: "server listener")
    
    private var connections : [Int : ServerConnection] = [:]
    
    // 状态回调
    public var stateChangeCallback : ((NWListener.State) -> Void)? = nil
    
    public init(port : UInt16) {
        self.port = NWEndpoint.Port(integerLiteral: port)
    }
    
    public func start() throws {
        NSLog("Server starting...")
        self.listener = try NWListener(using: .tcp, on: self.port)
        listener?.stateUpdateHandler = self.onStateChange(to:)
        listener?.newConnectionHandler = self.onAccept(newConnection:)
        listener?.start(queue: listenerQueue)
        NSLog("Server start on port [\(port)]")
    }
    
    public func stop() {
        self.listener?.cancel()
        for connection in self.connections.values {
            connection.onStop = nil
            connection.stop()
        }
        self.connections.removeAll()
        NSLog("Server stop submited.")
    }
    
    
    /// 服务器监听的状态变化
    /// - Parameter newState: 变化的状态
    private func onStateChange(to newState: NWListener.State) {
        stateChangeCallback?(newState)
        switch newState {
        case .ready:
            NSLog("Server ready.")
        case .failed(let error):
            NSLog("Server failure, error: \(error.localizedDescription)")
        case .cancelled:
            NSLog("Server cancelled.")
        default:
            break
        }
    }
    
    /// 监听客户端接入时间
    /// - Parameter newConnection: 新的接入连接
    private func onAccept(newConnection : NWConnection) {
        let connection = ServerConnection(connection: newConnection)
        NSLog("客户端[\(newConnection.endpoint.debugDescription)]已接入. connection id: \(connection.id)")
        self.connections[connection.id] = connection
        connection.onStop = { _ in
            self.onConnectionStop(connection)
        }
        
        connection.start()
    }
    
    /// 有连接关闭的时候调用
    /// - Parameter connection: 关闭的连接
    private func onConnectionStop(_ connection : ServerConnection) {
        self.connections.removeValue(forKey: connection.id)
        NSLog("server did close connection \(connection.id)")
    }
}
