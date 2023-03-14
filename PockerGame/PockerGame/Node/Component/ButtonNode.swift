//
//  ButtonNode.swift
//  PockerGame
//
//  Created by Wttch on 2023/3/10.
//

import SpriteKit

class ButtonNode : SKNode {
    override init() {
        super.init()
        
        let shape = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 16)
        shape.fillColor = .green
        shape.zPosition = 4
        addChild(shape)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
