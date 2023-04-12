//
//  ContentView.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/1.
//

import SwiftUI
import PockerCommon
import Charts

struct ContentView: View {

    @ObservedObject private var server : ObserableServer
    
    init() {
        server = ObserableServer(port: 8888)
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(server.state.foregroundColor)
                Text(server.state.desc)
                if server.state == .setup || server.state == .cancelled {
                    Button(action: {
                        try! server.start()
                    }, label: {
                        Text("开启服务器")
                    })
                }
                if server.state == .ready {
                    Button(action: {
                        server.stop()
                    }, label: {
                        Text("关闭服务器")
                    })
                }
            }
            TestView()
            List {
               
            }
        }.onAppear {
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TestView : NSViewRepresentable {
    typealias NSViewType = NSTextField
    
    func makeNSView(context: Context) -> NSTextField {

        let y = NSMutableAttributedString(string: "test", attributes: [
            .foregroundColor : NSColor.green
        ])
        let x = NSTextField()
        x.usesSingleLineMode = false
        x.allowsEditingTextAttributes = true
        let y1 = NSAttributedString(string: "test2", attributes: [
            .strokeColor : NSColor.blue
        ])
        y.append(y1)
        x.attributedStringValue = y
        return x
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        
    }
}
