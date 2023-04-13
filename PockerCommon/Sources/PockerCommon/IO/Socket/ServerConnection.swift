//
//  ServerConnection.swift
//  
//
//  Created by Wttch on 2023/4/9.
//

import Foundation
import Network

class ServerConnection : ConnectionBase, Identifiable {
    // 处理连接的 DispatchQueue
    static let connectionQueue : DispatchQueue = DispatchQueue(label: "server connection queue")
    // 静态变量: 下一个连接的 id
    private static var nextID : Int = 1
    
    typealias ID = Int
    // 连接 id
    let id : Int
    // 关闭回调
    var onStop : ((Error?) -> Void)? = nil
    
    init(connection: NWConnection) {
        self.id = ServerConnection.nextID
        ServerConnection.nextID += 1
        super.init(connection: connection, connectionQueue: ServerConnection.connectionQueue, label: "Server")
    }
    
    override func stop() {
        super.stop()
        NSLog("connectin id:\(id) stop.")
    }
    
    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        if let onStop = onStop {
            self.onStop = nil
            onStop(error)
        }
    }
}
