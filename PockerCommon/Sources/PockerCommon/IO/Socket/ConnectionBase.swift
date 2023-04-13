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
    
    public func start() {
        NSLog("\(label) Connection[\(connection.endpoint.debugDescription)] starting...")
        connection.stateUpdateHandler = self.onStateChange(state:)
        connection.start(queue: connectionQueue)
        NSLog("\(label) Connection[\(connection.endpoint.debugDescription)] started.")
        // 开始心跳
        heartBeatTask = ConnectionBase.heartBeat.schedule(after: .init(.now() + 2), interval: .seconds(2), {
            self.sendMessage(opCode: rcOpCode, subCode: rcHeartBeat, data: nil)
            NSLog("心跳已发送...")
        })
        
        // 开始数据接收
    }
    
    func stop() {
        NSLog("Connection shutdowning...")
        connection.cancel()
        NSLog("Connection shutdowned.")
    }
    
    func connectionDidFail(error : Error?) {
        // 保证失败只调用一次, 然后就关闭连接
        if self.connection.stateUpdateHandler != nil {
            self.connection.stateUpdateHandler = nil
            NSLog("connection fail: \(error?.localizedDescription)")
            // TODO 服务端心跳失败直接断开，客户端心跳失败断开重连！
            self.heartBeatTask?.cancel()
            self.stop()
        }
    }
    // MARK: 状态监听
    private func onStateChange(state: NWConnection.State) {
        switch state {
        case .ready:
            onReady()
        case .cancelled:
            onCancelled()
        case .failed(let error):
            onFailed(error: error)
        case .setup:
            onSetup()
        case .preparing:
            onPreparing()
        case .waiting(let error):
            onWaiting(error: error)
        default: break
        }
    }
    
    func onSetup() {
        NSLog("state change -> [setup]")
    }
    
    func onPreparing() {
        NSLog("state change -> [preparing]")
    }
    
    func onReady() {
        NSLog("state change -> [ready]")
    }
    
    func onCancelled() {
        NSLog("state change -> [canceled]")
    }
    
    func onWaiting(error: Error) {
        NSLog("state change -> [waiting]:\(error.localizedDescription)")
    }
    
    func onFailed(error : Error) {
        NSLog("state change -> [failed]:\(error.localizedDescription)")
    }
    
    // MARK: 发送数据
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
            self.connectionDidFail(error: error)
        }))
    }
    
    func sendUInt32(_ data : UInt32) {
        connection.send(content: data.toData(), completion: .contentProcessed({ error in
            self.connectionDidFail(error: error)
        }))
    }
    
    // MARK: 接收数据
    
    func setupReceive() {
        self.receiveMessage { opCode, subCode, data in
            if opCode == 1 && subCode == rcHeartBeat {
                NSLog("收到心跳.")
            }
            self.setupReceive()
        }
    }
    
    func connectionDidEnd() {
        
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
                self.stop()
            }
        }
    }
    
    func receiveData(length : UInt32, _ callback : @escaping (Data) -> Void) {
        receiveData(length: length, format: { $0 }, callback)
    }
    
    func receiveData<T>(length : UInt32, format : @escaping (Data) -> T, _ callback : @escaping (T) -> Void) {
        let length = Int(length)
        
        connection.receive(minimumIncompleteLength: length, maximumLength: length) { content, contentContext, isComplete, error in
            if let content = content {
                callback(format(content))
            } else {
                NSLog("receive content is nil.")
            }
        }
    }
    
    func receiveUInt32(_ callback : @escaping (UInt32) -> Void) {
        self.receiveData(length: 4, format: { $0.toUInt32() }, callback)
    }
    
    func receiveMagicNumber(_ callback : @escaping (UInt32) -> Void) {
        receiveUInt32(callback)
    }
}
