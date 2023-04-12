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
    
    func start() {
        self.start(onStateChange: self.onStateChange(state:))
    }
    
    func stop() {
        NSLog("connectin(id:\(id) stop.")
    }
    
    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        if let onStop = onStop {
            self.onStop = nil
            onStop(error)
        }
    }
    
    func onStateChange(state : NWConnection.State) {
        switch(state) {
        case.ready:
            NSLog("Server connection ready.")
            for i in 0..<10 {
                self.sendMessage(opCode: 1, data: "你好客户端".data(using: .utf8)!)
                self.sendMessage(opCode: 1, data: "你好客户端1111".data(using: .utf8)!)
                self.sendMessage(opCode: 1, data: "你好客户端2222".data(using: .utf8)!)
                self.sendMessage(opCode: 1, data: "你好客户端3333".data(using: .utf8)!)
                Thread.sleep(forTimeInterval: 0.2)
            }
            connection.cancel()
//            for i in 0..<1000 {
//                let data = "testoaeuaosuthoaseuthosuhoaeuthaoseuhtaoesuhot".count.toData()
//                connection.send(content: data, completion: .contentProcessed({ error in
//
//                }))
//                connection.send(content: "testoaeuaosuthoaseuthosuhoaeuthaoseuhtaoesuhot".data(using: .utf8), completion: .contentProcessed({ error in
//                    NSLog("服务器已发送:\(error?.errorCode)")
//                }))
//            }
        default:
            break
        }
    }
    
    
}
