//
//  GameScene.swift
//  GEExampleApp
//
//  Created by Papp Oliver on 2016. 05. 13..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var mBallNode: SKSpriteNode?
    var mNodes: [SKSpriteNode] = [SKSpriteNode]()
    override func didMoveToView(view: SKView) {
        //self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.blackColor()

        let resetNode = SKLabelNode(text: "Reset")
        resetNode.fontSize = 70
        resetNode.fontColor = UIColor.whiteColor()
        resetNode.position = CGPoint(self.frame.midX, self.frame.maxY - 150)
        self.addChild(resetNode)

        for _ in 0...700 {
            let node = Cache.sharedInstance.getSKSpriteNode("cube")
            node.position = CGPoint(randomFloat(0, to: self.frame.width), randomFloat(0, to: self.frame.height))
            node.setScale(randomFloat(0.002, to: 0.015))
            self.addChild(node)
        }

        reinit()
    }

    func reinit() {
        for node in mNodes {
            node.removeFromParent()
        }
        let space = self.frame.size.width / 8
        let rightAction = SKAction.moveByX(space/2 * -1, y: 0.0, duration: 5)
        let leftAction = SKAction.moveByX(space/2, y: 0.0, duration: 5)
        let seq = SKAction.sequence([rightAction, leftAction])
        let rep = SKAction.repeatActionForever(seq)

        if let node = loadGEObject("tree", hasPhysics: false) {
            node.position = CGPoint(self.frame.midX + 400, 50)
            node.setScale(node.xScale * 0.6)
            node.runAction(rep)
            mNodes.append(node)
            self.addChild(node)
        }
        if let node = loadGEObject("tree2", hasPhysics: true) {
            node.position = CGPoint(self.frame.midX, 50)
            node.setScale(node.xScale * 0.7)
            node.runAction(rep)
            mNodes.append(node)
            self.addChild(node)
        }
        if let node = loadGEObject("brush1", hasPhysics: true) {
            node.position = CGPoint(self.frame.midX - 400, 50)
            node.setScale(node.xScale * 0.6)
            node.runAction(rep)
            mNodes.append(node)
            self.addChild(node)
        }
        if let node = loadGEObject("brush1", hasPhysics: false) {
            node.position = CGPoint(self.frame.midX + 200, 50)
            node.setScale(node.xScale * 0.5)
            node.runAction(rep)
            mNodes.append(node)
            self.addChild(node)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) where node as? SKLabelNode {
                reinit()
                return
            }
            if let node = mBallNode {
                node.runAction(SKAction.moveTo(location, duration: 0.2))
            } else {
                mBallNode = Cache.sharedInstance.getSKSpriteNode("ball")
                mBallNode?.position = location
                mBallNode?.setScale(0.4)
                mBallNode?.physicsBody = SKPhysicsBody(circleOfRadius: mBallNode!.frame.size.width * 0.27)
                mBallNode?.physicsBody?.affectedByGravity = false
                mBallNode?.physicsBody?.dynamic = false
                mBallNode?.physicsBody?.allowsRotation = false
                mBallNode?.physicsBody?.contactTestBitMask = GEObjectCategory
                mBallNode?.physicsBody?.categoryBitMask = ContactTestCategory
                self.addChild(mBallNode!)
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)

            if let node = mBallNode {
                node.runAction(SKAction.moveTo(location, duration: 0.2))
            }
        }
    }

    func loadGEObject(path: String, hasPhysics: Bool) -> SKSpriteNode? {
        if let objPath = NSBundle.mainBundle().pathForResource(path, ofType: "json") {
            if let node = GEObject(path: objPath, hasPhysics: hasPhysics) {
                return node.getNode()
            }
        }

        return nil
    }

    // MARK: - Physics section
    ////////////////////////////////////////////////////////////////////////////

    func didBeginContact(contact: SKPhysicsContact) {
        GEOPhysics.didBeginContact(contact)
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
