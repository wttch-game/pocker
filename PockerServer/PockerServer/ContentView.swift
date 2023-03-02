//
//  ContentView.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/1.
//

import SwiftUI
import NIO
import CocoaLumberjackSwift

struct ContentView: View {
    @State var state : PockerServerState = .notStart
    
    private var pockerServer : PockerServer
    
    init() {
        self.pockerServer = PockerServer()
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(state.rawValue)
            if state == .notStart {
                Button(action: {
                    pockerServer.startBind()
                }, label: {
                    Text("开启服务器")
                })
            }
            if state == .success {
                Button(action: {
                    pockerServer.shutdown()
                }, label: {
                    Text("关闭服务器")
                })
            }
        }.onAppear {
            DDLog.add(DDOSLogger.sharedInstance)
            self.pockerServer.addCallback({ state in
                self.state = state
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
