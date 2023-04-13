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
    
    override func onReady() {
        NSLog("Client connection ready.")
        let t = DispatchQueue(label: "test", qos: .background)
        t.async {
            self.setupReceive()
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
}
