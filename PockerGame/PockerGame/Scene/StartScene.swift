//
//  StartScene.swift
//  PockerGame
//
//  Created by Wttch on 2023/3/10.
//


import SpriteKit
import SwiftUI

class StartScene: SKScene {
    override func didMove(to view: SKView) {
        let shape = ButtonNode()
        addChild(shape)
        
        let tv = NSTextView(frame: NSRect(x: 10, y: 10, width: 100, height: 48))
        tv.backgroundColor
        let x = self.scene?.view
        self.scene?.view?.addSubview(tv)
    }
}
