//
//  ConnectionBase.swift
//  
//
//  Created by Wttch on 2023/4/9.
//

import Foundation
import Network
import Combine


public class ConnectionBase {
    var connection : NWConnection
    // 连接用的 DispatchQueue
    var connectionQueue : DispatchQueue
    // 心跳用的 DispatchQueeu
    private static let heartBeat : DispatchQueue = DispatchQueue(label: "heart beat queue", qos: .background)
    // 心跳任务
    private var heartBeatTask : Cancellable? = nil
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
        // 开始心跳
        heartBeatTask = ConnectionBase.heartBeat.schedule(after: .init(.now() + 2), interval: .seconds(2), {
            self.sendMessage(opCode: rcOpCode, subCode: rcHeartBeat, data: nil)
            NSLog("心跳已发送...")
        })
    }
    
    func shutdown() {
        NSLog("Connection shutdowning...")
        connection.cancel()
        NSLog("Connection shutdowned.")
    }
    
    func onError(error : Error?) {
        NSLog("error \(error?.localizedDescription)")
        // TODO 服务端心跳失败直接断开，客户端心跳失败断开重连！
        self.heartBeatTask?.cancel()
        self.shutdown()
    }
    
    func sendMessage(opCode : UInt32, subCode: UInt32 = 0, data : Data?) {
        sendMagicNumber()
        sendUInt32(opCode)
        sendUInt32(subCode)
        if let data = data {
            sendUInt32(UInt32(data.count))
            sendData(data: data)
        } else {
            sendUInt32(0)
        }
    }
    
    private func sendMagicNumber() {
        sendUInt32(magicNumber)
    }
    
    func sendData(data : Data) {
        connection.send(content: data, completion: .contentProcessed({ error in
            self.onError(error: error)
        }))
    }
    
    func sendUInt32(_ data : UInt32) {
        connection.send(content: data.toData(), completion: .contentProcessed({ error in
            self.onError(error: error)
        }))
    }
    
    func receiveMessage(_ callback : @escaping (UInt32, UInt32, Data?) -> Void) {
        self.receiveMagicNumber { mu in
            if mu == magicNumber {
                self.receiveUInt32 { opCode in
                    NSLog("opCode : \(opCode)")
                    self.receiveUInt32 { subCode in
                        self.receiveUInt32 { length in
                            NSLog("length : \(length)")
                            if length != 0 {
                                self.receiveData(length: length) { data in
                                    callback(opCode,subCode, data)
                                }
                            } else {
                                callback(opCode,subCode, nil)
                            }
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
