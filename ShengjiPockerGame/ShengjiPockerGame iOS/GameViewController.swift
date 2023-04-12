//
//  GameViewController.swift
//  ShengjiPockerGame iOS
//
//  Created by Wttch on 2023/3/13.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var skView : SKView {
        get {
            return self.view as! SKView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = StartScene.newScene()

        // Present the scene
        let skView = self.skView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let mainView = MainView(frame: skView.frame)
                skView.addSubview(mainView)
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
