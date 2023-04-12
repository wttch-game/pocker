//
//  ObserableServer.swift
//  PockerServer
//
//  Created by Wttch on 2023/4/12.
//

import Foundation
import Network
import PockerCommon

class ObserableServer : SocketServer, ObservableObject {
    
    @Published var state : NWListener.State = .setup
    
    override init(port: UInt16) {
        super.init(port: port)
        self.stateChangeCallback = self.stateCallback
    }
    
    private func stateCallback(newState : NWListener.State) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }
}
