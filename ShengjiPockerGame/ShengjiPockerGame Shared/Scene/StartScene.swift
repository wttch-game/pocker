//
//  StartScene.swift
//  ShengjiPockerGame
//
//  Created by Wttch on 2023/3/13.
//

import Foundation

import SpriteKit
import SwiftUI

class StartScene: SKScene {
    override func didMove(to view: SKView) {
        addTextFieldView(view)
    }
}

class testNode: SKNode {
    
}



#if os(iOS) || os(tvOS)
extension StartScene {
    func addTextFieldView(_ view: SKView) {
        NSLog("\(view.frame.size)")
//        let tv = UITextView(frame: CGRect(x: 100, y: 100, width: 120, height: 36))
//        tv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//        tv.layer.cornerRadius = 10
//        view.addSubview(tv)
//
//        let btn = UIButton(frame: CGRect(x: 200, y: 200, width: 120, height: 36))
//        let lab = UILabel()
//        lab.text = "登录"
//        btn.setTitle("登陆", for: .normal)
//        btn.backgroundColor = .blue
//        btn.layer.cornerRadius = 10
//        view.addSubview(btn)
        
        let x = LoginPanel(frame: view.frame)
        view.addSubview(x)
    }
}
#endif




#if os(OSX)
extension StartScene {
    func addTextFieldView(_ view: SKView) {
        
    }
}
#endif

