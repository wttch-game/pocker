//
//  SocketClient.swift
//  
//
//  Created by Wttch on 2023/4/8.
//

import Foundation
import Network

public class SocketClient : ConnectionBase {
    static let connectionQueue : DispatchQueue = DispatchQueue(label: "client connection queue")
    
    let x = 0x19960818
    
    public init(host : String, port : UInt16) {
        let connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port), using: .tcp)
        super.init(connection: connection, connectionQueue: SocketClient.connectionQueue, label: "Client")
    }
    
    public func start() {
        self.start(onStateChange: self.onStateChange(state:))
    }
    
    func onStateChange(state: NWConnection.State) {
        switch state {
        case .ready:
            NSLog("Client connection ready.")
            let t = DispatchQueue(label: "test", qos: .background)
            t.async {
               
                self.receiveStr()
            }
        default: break
        }
    }
    
    func receiveStr() {
        self.receiveMessage { opCode, subCode, data in
            if opCode == 1 && subCode == rcHeartBeat {
                NSLog("收到心跳.")
                self.receiveStr()
            }
        }
    }
    
    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4) { content, contentContext, isComplete, error in
            let cnt = content!.toInt()
            NSLog("cnt \(cnt)")
            self.connection.receive(minimumIncompleteLength: cnt, maximumLength: cnt) { content, contentContext, isComplete, error in
                NSLog("收到:\(String(data: content!, encoding: .utf8)!)")
                self.receive()
            }
        }
    }
  
   public func test() {
       //监听连接状态
       connection.start(queue: DispatchQueue(label: "client connection"))
       NSLog("客户端已启动...")
    }
}
