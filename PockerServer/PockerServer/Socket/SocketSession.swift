//
//  SocketSession.swift
//  PockerServer
//
//  Created by Wttch on 2023/4/14.
//

import Foundation
import Network

class SocketSessionManager {
    
}

class SocketSession : ObservableObject {
    var connection : NWConnection? = nil
    var attributes : [String : Any] = [:]
    
    init() {
        
    }
    
    enum State {
        
    }
}
