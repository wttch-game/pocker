//
//  ContentView.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/1.
//

import SwiftUI
import NIO

struct ContentView: View {
    @State var state : String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(state)
            Button(action: {
                DispatchQueue.global(qos: .background).async {
                    PockerServer().bind { state in
                        self.state = state.rawValue
                    }
                }
            }, label: {
                Text("开启服务器")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
