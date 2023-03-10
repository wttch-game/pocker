//
//  ViewController.swift
//  PockerGame
//
//  Created by Wttch on 2023/3/2.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.setFrameSize(NSSize(width: 960, height: 640))
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

