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
}
