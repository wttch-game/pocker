//
//  MainView.swift
//  ShengjiPockerGame iOS
//
//  Created by Wttch on 2023/3/14.
//

import SwiftUI
import SpriteKit
import PockerCommon

class MainView : UIView {
    private let startPanel : StartPanel
    private let loginPanel : LoginPanel
    private let client : SocketClient
    
    override init(frame: CGRect) {
        loginPanel = LoginPanel(frame: frame)
        startPanel = StartPanel(frame: frame)
        self.client = SocketClient(host: "127.0.0.1", port: 8888)
        self.client.start()
        super.init(frame: frame)
        
        showStartPanel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("MainView init(NSCoder)未实现...")
    }
    
    private func showStartPanel() {
        addSubview(startPanel)
        startPanel.btnLogin.addTarget(self, action: #selector(onRegisterClick), for: .touchUpInside)
        loginPanel.btnCancel.addTarget(self, action: #selector(onLoginCancel), for: .touchUpInside)
        loginPanel.btnLogin.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
    }
    
    // MARK: 事件响应
    // 注册点击
    @objc func onRegisterClick() {
        startPanel.removeFromSuperview()
        addSubview(loginPanel)
    }
    
    // 取消登录
    @objc func onLoginCancel() {
        loginPanel.removeFromSuperview()
        addSubview(startPanel)
    }
    
    // 登录
    @objc func onLogin() {
        NSLog("尝试登录")
        loginPanel.removeFromSuperview()
        let value = LoginRequestDto(username : "", password : "")
        let msg = value.toMessage()
        // client.sendMessage(msg)
    }
}
