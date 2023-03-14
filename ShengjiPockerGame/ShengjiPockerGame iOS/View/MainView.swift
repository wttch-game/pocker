//
//  MainView.swift
//  ShengjiPockerGame iOS
//
//  Created by Wttch on 2023/3/14.
//

import SwiftUI
import SpriteKit
import PockerCommon
import CocoaLumberjackSwift

class MainView : UIView {
    private let startPanel : StartPanel
    private let loginPanel : LoginPanel
    private let client : PockerSocketClient
    
    init(frame: CGRect, client : PockerSocketClient) {
        loginPanel = LoginPanel(frame: frame)
        startPanel = StartPanel(frame: frame)
        self.client = client
        super.init(frame: frame)
        
        showStartPanel()
    }
    
    private func showStartPanel() {
        addSubview(startPanel)
        startPanel.btnLogin.addTarget(self, action: #selector(onRegisterClick), for: .touchUpInside)
        loginPanel.btnCancel.addTarget(self, action: #selector(onLoginCancel), for: .touchUpInside)
        loginPanel.btnLogin.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
    }
    
    @objc func onRegisterClick() {
        startPanel.removeFromSuperview()
        addSubview(loginPanel)
    }
    
    @objc func onLoginCancel() {
        loginPanel.removeFromSuperview()
        addSubview(startPanel)
    }
    
    @objc func onLogin() {
        NSLog("尝试登录")
        loginPanel.removeFromSuperview()
        let value = LoginMessageValue(username : "", password : "")
        let msg = value.toMessage()
        client.sendMessage(msg)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MainView init(NSCoder)未实现...")
    }
}
