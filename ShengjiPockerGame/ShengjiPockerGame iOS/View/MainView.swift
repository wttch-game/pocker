//
//  MainView.swift
//  ShengjiPockerGame iOS
//
//  Created by Wttch on 2023/3/14.
//

import SwiftUI

class MainView : UIView {
    private let startPanel : StartPanel
    private let loginPanel : LoginPanel
    
    override init(frame: CGRect) {
        loginPanel = LoginPanel(frame: frame)
        startPanel = StartPanel(frame: frame)
        super.init(frame: frame)
        
        showStartPanel()
    }
    
    private func showStartPanel() {
        addSubview(startPanel)
        startPanel.btnLogin.addTarget(self, action: #selector(onRegisterClick), for: .touchUpInside)
        loginPanel.btnCancel.addTarget(self, action: #selector(onLoginCancel), for: .touchUpInside)
    }
    
    @objc func onRegisterClick() {
        startPanel.removeFromSuperview()
        addSubview(loginPanel)
    }
    
    @objc func onLoginCancel() {
        loginPanel.removeFromSuperview()
        addSubview(startPanel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MainView init(NSCoder)未实现...")
    }
}
