//
//  ConnectionBase.swift
//  
//
//  Created by Wttch on 2023/4/9.
//

import Foundation
import Network


public class ConnectionBase {
    var connection : NWConnection
    var connectionQueue : DispatchQueue
    var label : String
    
    init(connection: NWConnection, connectionQueue: DispatchQueue, label: String) {
        self.connection = connection
        self.connectionQueue = connectionQueue
        self.label = label
    }
    
    func start(onStateChange : @escaping (NWConnection.State) -> Void) {
        NSLog("\(label) Connection[\(connection.endpoint.debugDescription)] starting...")
        connection.stateUpdateHandler = onStateChange
        connection.start(queue: connectionQueue)
        NSLog("\(label) Connection[\(connection.endpoint.debugDescription)] started.")
    }
    
    func shutdown() {
        NSLog("Connection shutdowning...")
        connection.cancel()
        NSLog("Connection shutdowned.")
    }
    
    func sendMessage(opCode : UInt32, data : Data) {
        sendMagicNumber()
        sendUInt32(opCode)
        sendUInt32(UInt32(data.count))
        sendData(data: data)
    }
    
    private func sendMagicNumber() {
        sendUInt32(magicNumber)
    }
    
    func sendData(data : Data) {
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                NSLog("\(error.localizedDescription)")
            }
        }))
    }
    
    func sendUInt32(_ data : UInt32) {
        connection.send(content: data.toData(), completion: .contentProcessed({ error in
            if let error = error {
                NSLog("\(error.localizedDescription)")
            }
        }))
    }
    
    func receiveMessage(_ callback : @escaping (UInt32, Data) -> Void) {
        self.receiveMagicNumber { mu in
            if mu == magicNumber {
                self.receiveUInt32 { opCode in
                    NSLog("opCode : \(opCode)")
                    self.receiveUInt32 { length in
                        NSLog("length : \(length)")
                        self.receiveData(length: length) { data in
                            callback(opCode, data)
                        }
                    }
                }
            } else {
                NSLog("magic number error.")
                self.shutdown()
            }
        }
    }
    
    func receiveData(length : UInt32, _ callback : @escaping (Data) -> Void) {
        let length = Int(length)
        connection.receive(minimumIncompleteLength: 1, maximumLength: length) { content, contentContext, isComplete, error in
            if let content = content {
                callback(content)
            } else {
                NSLog("receive content is nil.")
                self.shutdown()
            }
        }
    }
    
    func receiveUInt32(_ callback : @escaping (UInt32) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4) { content, contentContext, isComplete, error in
            if let content = content {
                if content.count == 4 {
                    callback(content.toUInt32())
                    return
                }
            }
            NSLog("receive content is nil.\(content?.count)")
            self.shutdown()
        }
    }
    
    func receiveMagicNumber(_ callback : @escaping (UInt32) -> Void) {
        receiveUInt32(callback)
    }
}
