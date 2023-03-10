//
//  StartScene.swift
//  PockerGame
//
//  Created by Wttch on 2023/3/10.
//


import SpriteKit

class StartScene: SKScene {
    override func didMove(to view: SKView) {
        let shape = SKShapeNode(rectOf: CGSize(width: 200, height: 300), cornerRadius: 16)
        shape.fillColor = .green
        shape.zPosition = 4
        addChild(shape)
    }
}
