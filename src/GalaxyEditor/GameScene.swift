//
//  GameScene.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 03..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Initialization
    ////////////////////////////////////////////////////////////////////////////

    var mActiveCube: SKSpriteNode = SKSpriteNode()
    var mItemID: Int = 0
    var mGridLines: [SKShapeNode] = [SKShapeNode]()
    var mNodes: [SKSpriteNode] = [SKSpriteNode]()
    var mPrecCube: SKSpriteNode = Cache.sharedInstance.getSKSpriteNode("cube")
    var mColor: NSColor = NSColor.white
    var mSpace: CGFloat = 0.0
    var mRowCount: Int  = 0
    var mColCount: Int = 0
    var mDrawingLine: Bool = false
    var mRemoveActive: Bool = false
    var mRefSwitchActive: Bool = false
    var mPrevPoint: CGPoint = CGPoint.zero
    var mScale: CGFloat = 0.0

    override func didMove(to view: SKView) {
        self.backgroundColor = NSColor.black
        mPrecCube.alpha = 0
        self.addChild(mPrecCube)
        
        mSpace = self.frame.size.width / 80
        mRowCount = Int(self.frame.size.height / CGFloat(Int(mSpace)))
        mColCount = Int(self.frame.size.width / CGFloat(Int(mSpace)))
        showGrid(Settings.sharedInstance.gridShowed)
        let node = Cache.sharedInstance.getSKSpriteNode("cube")
        mScale = (self.frame.size.width / (CGFloat(mColCount))) / node.size.height * 0.8
        mColor = NSColor(hexString: "#ffffff")
        self.physicsWorld.contactDelegate = self
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
			self.keyDown(with: aEvent)
			return aEvent
		}
		NSEvent.addLocalMonitorForEvents(matching: .keyUp) { (aEvent) -> NSEvent? in
			self.keyUp(with: aEvent)
			return aEvent
		}
    }
    
    // MARK: - Nodes Handling
    ////////////////////////////////////////////////////////////////////////////

    func loadFromData() {
        clearNodes()
        var origo = CGPoint.zero
        let data: JSON = DataManager.sharedInstance.getData()
        if let scale = data["scale"].double {
            mScale = CGFloat(scale)
            if let arrayObject = data["nodes"].arrayObject {
                for i in 0...arrayObject.count-1 {
                    let x = data["nodes"][i][1]["posX"].doubleValue
                    let y = data["nodes"][i][2]["posY"].doubleValue
                    var position = CGPoint(x: x, y: y)
                    if i == 0 {
                        origo = position
                    } else {
                        let x = origo.x + position.x
                        let y = origo.y + position.y
                        position = CGPoint(x: x, y: y)
                    }
                    let color = String(data["nodes"][i][3]["color"].stringValue)
                    let tmpColor = mColor
                    mColor = NSColor(hexString: color!)
                    let itemID = data["nodes"][i][0]["id"].intValue
                    createNodeAtPoint(position, itemID: itemID, ignoreCorrigation: true)
                    mColor = tmpColor
                }
            }
        } else {
            print(data["scale"].error ?? "")
        }
    }

    func save() {
        var scale = 0.0
        if let firstNode = mNodes.first {
            for node in mNodes {
                if let name = node.name {
                    scale = Double(node.xScale)
                    let parts = name.components(separatedBy: "_")
                    if parts.count == 4 {
                        let id = Int(parts[1])!
                        let colorHex = parts[3]
                        if name != firstNode.name {
                            var x = node.position.x - firstNode.position.x
                            var y = node.position.y - firstNode.position.y

                            if firstNode.position.x > node.position.x {
                                x = firstNode.position.x - node.position.x
                                x *= -1
                            }

                            if firstNode.position.y > node.position.y {
                                y = firstNode.position.y - node.position.y
                                y *= -1
                            }

                            DataManager.sharedInstance.addNodeToData("\(id)_\(colorHex)_\(x)_\(y)")
                        } else {
                            DataManager.sharedInstance.addNodeToData("\(id)_\(colorHex)_\(node.position.x)_\(node.position.y)")
                        }
                    }
                }
            }
        }
        DataManager.sharedInstance.dumpData(scale)
    }
    
    func clearNodes() {
        for node in mNodes {
            node.run(destroyAction)
        }
        mNodes.removeAll()
    }

    func removeNode(_ node: SKSpriteNode) {
		if !mNodes.isEmpty {
        	for i in 0...mNodes.count-1 where mNodes[i] == node {
            	node.run(destroyAction)
                mNodes.remove(at: i)
                break
        	}
		}
    }

    func selectReferenceNode(_ refNode: SKSpriteNode) {
        if let i = mNodes.index(of: refNode) {
            mNodes.remove(at: i)
            mNodes.insert(refNode, at: 0)
            refNode.run(SKAction.repeat(SKAction.rotate(byAngle: CGFloat.pi, duration: 0.5), count: 2))
        }
    }

    @discardableResult
    func createNodeAtPoint(_ point: CGPoint, itemID: Int = 0, ignoreCorrigation: Bool = false) -> SKSpriteNode {
        if itemID > 0 {
            mItemID = itemID
        } else {
            mItemID += 1
        }

        let node = Cache.sharedInstance.getSKSpriteNode("cube")
        node.position = point
        node.setScale(mScale)
        node.name = "cube_\(mItemID)_color_\(mColor.getHexString())"
        node.run(SKAction.colorize(with: mColor, colorBlendFactor: 1, duration: 0), withKey: "coloroze")
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.contactTestBitMask = sGEObjectCategory
        node.physicsBody?.categoryBitMask = sContactTestCategory
        self.addChild(node)
        mNodes.append(node)
        if !ignoreCorrigation {
            corrigateNode(node)
        }

        return node
    }

    func corrigateNode(_ node: SKSpriteNode) {
        let diffX = node.position.x.truncatingRemainder(dividingBy: mSpace)
        let diffY = node.position.y.truncatingRemainder(dividingBy: mSpace)
        let newX = min(node.position.x + diffX, node.position.x - diffX)
        let newY = min(node.position.y + diffY, node.position.y - diffY)

        node.run(SKAction.move(to: CGPoint(x: newX, y: newY), duration: 1), withKey: "move")
    }

    // MARK: - Grid visualizations
    ////////////////////////////////////////////////////////////////////////////

    func createGrid() {
        for i in 0...mColCount+1 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(Int(mSpace)) * CGFloat(i), y: self.frame.size.height))
            path.addLine(to: CGPoint(x: CGFloat(Int(mSpace)) * CGFloat(i), y: 0))

            let shapeNode = createLine(path)
            self.addChild(shapeNode)
            mGridLines.append(shapeNode)
        }

        for i in 1...mRowCount {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(Int(mSpace)) * -1, y: CGFloat(Int(mSpace)) * CGFloat(i)))
            path.addLine(to: CGPoint(x: self.frame.size.width + CGFloat(Int(mSpace)), y: CGFloat(Int(mSpace)) * CGFloat(i)))
            
            let shapeNode = createLine(path)
            self.addChild(shapeNode)
            mGridLines.append(shapeNode)
        }
        for line in mGridLines {
            line.run(SKAction.fadeAlpha(to: 0.2, duration: 1))
        }
    }

    func createLine(_ path: CGMutablePath) -> SKShapeNode {
        let shapeNode = SKShapeNode()
        shapeNode.path = path
        shapeNode.strokeColor = NSColor.gray
        shapeNode.lineWidth = 1
        shapeNode.zPosition = 1
        shapeNode.alpha = 0.0

        return shapeNode
    }

    func showGrid(_ enabled: Bool) {
        if enabled {
            createGrid()
        } else {
            for line in mGridLines {
                line.run(destroyAction)
            }
            mGridLines.removeAll()
        }
    }

    // MARK: - UI functions
    ////////////////////////////////////////////////////////////////////////////

    func showColor(_ color: NSColor) {
        mPrecCube.run(SKAction.colorize(with: NSColor.white, colorBlendFactor: 1, duration: 0.0), withKey: "coloroze")
        mPrecCube.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        mPrecCube.setScale(0.5)
        mPrecCube.run(SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.5), withKey: "coloroze")
        let locDestroyAction = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2),
            SKAction.fadeOut(withDuration: 0.5)
            ])
        mPrecCube.run(locDestroyAction, withKey: "destroy")
        mColor = color
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func keyDown(with theEvent: NSEvent) {
        if theEvent.keyCode == 15 {
            if !mRefSwitchActive {
                NSCursor.pop()
                NSCursor.pointingHand().push()
                mRefSwitchActive = true
            }
        } else if theEvent.keyCode == 2 {
            if !mRemoveActive {
                NSCursor.pop()
                NSCursor.disappearingItem().push()
                mRemoveActive = true
            }
        }
    }

    override func keyUp(with theEvent: NSEvent) {
        if theEvent.keyCode == 15 {
            NSCursor.pop()
            mRefSwitchActive = false
        } else if theEvent.keyCode == 2 {
            NSCursor.pop()
            mRemoveActive = false
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        let nodesAtPoint = self.nodes(at: location)
        for node in nodesAtPoint {
            if let name = node.name, let parent = node.parent as? SKSpriteNode {
                if name.contains("game") {
                    mActiveCube = parent
                    mDrawingLine = false
                    return
                } else if name.contains("cube") {
                    mActiveCube = parent
                    mDrawingLine = false
                    if mRefSwitchActive {
                        selectReferenceNode(mActiveCube)
                    } else if mRemoveActive {
                        removeNode(mActiveCube)
                    }
                    return
                }
            }
        }
        mDrawingLine = true
        mPrevPoint = location
        mActiveCube = createNodeAtPoint(location)
    }

    override func mouseDragged(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        if mRemoveActive {
            let nodesAtPoint = self.nodes(at: location)
            for node in nodesAtPoint {
                if let name = node.name, let activeNode = node as? SKSpriteNode {
                    if name.contains("cube") {
                        removeNode(activeNode)
                        return
                    }
                }
            }
        } else if mDrawingLine {
            if location.distanceToPoint(mPrevPoint) > mActiveCube.size.width * 1.1 {
                mPrevPoint = location
                createNodeAtPoint(location)
            }
        } else if !mRefSwitchActive {
            mActiveCube.position = theEvent.location(in: self)
        }
    }

    override func mouseUp(with theEvent: NSEvent) {
        if mRefSwitchActive || mRemoveActive {
            return
        }
        if !mDrawingLine {
            mActiveCube.position = theEvent.location(in: self)
        }

        corrigateNode(mActiveCube)
    }

    // MARK: - Physics section
    ////////////////////////////////////////////////////////////////////////////

    func didBegin(_ contact: SKPhysicsContact) {
        GEOPhysics.didBeginContact(contact)
    }

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
