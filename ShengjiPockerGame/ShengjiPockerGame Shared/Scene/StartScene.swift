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
        
    }
    
    class func newScene() -> StartScene {
        guard let scene = SKScene(fileNamed: "StartScene") as? StartScene else {
            print("Failed to load StartScene.sks")
            abort()
        }
        
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
}

class testNode: SKNode {
    
}
