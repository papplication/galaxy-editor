//
//  DataManager.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 05..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import SpriteKit

typealias ObjectPair = [String: AnyObject]
typealias NodeElement = [ObjectPair]
typealias NodesArray = [NodeElement]

class DataManager {

    fileprivate var mData: JSON = JSON("")
    fileprivate var mNodesArray: NodesArray = []

    class var sharedInstance: DataManager {
        struct Static {
            static let instance = DataManager()
        }
        return Static.instance
    }

    func setData(_ data: Data) {
        do {
            mData = try JSON(data: data)
        } catch {
            mData = JSON.null
        }
    }

    func getData() -> String {
        return mData.description
    }

    func getData() -> JSON {
        return mData
    }

    func dumpData(_ scale: Double) {
        var json: JSON =  ["scale": scale as AnyObject]
        json["nodes"].arrayObject = mNodesArray as [AnyObject]
        mData = json
        mNodesArray = []
    }

    func addNodeToData(_ data: String) {
        var parts = data.components(separatedBy: "_")
        if parts.count == 4 {
            if let id = Int(parts[0]), let x = Double(parts[2]), let y = Double(parts[3]) {
                let color = parts[1]
                var node: NodeElement = []
                node.append(["id": id as AnyObject])
                node.append(["posX": x as AnyObject])
                node.append(["posY": y as AnyObject])
                node.append(["color": color as AnyObject])
                mNodesArray.append(node)
            }
        }
    }

    func getNode(_ hasPhysics: Bool) -> SKSpriteNode {
        let parentNode = SKSpriteNode()
        if let scale = mData["scale"].double {
            if let arrayObject = mData["nodes"].arrayObject {
                var nodes: Set<String> = []
                for index in 0...arrayObject.count-1 {
                    let i = index == 0 ? index : arrayObject.count - index
                    let x = mData["nodes"][i][1]["posX"].doubleValue
                    let y = mData["nodes"][i][2]["posY"].doubleValue
                    let positionString = "\(x)_\(y)"

                    if (x != 0 || y != 0) && !nodes.contains(positionString) {
                        let id = mData["nodes"][i][0]["id"]
                        let color = String(mData["nodes"][i][3]["color"].stringValue)
                        let colorValue = NSColor(hexString: color!)
                        let node = Cache.sharedInstance.getSKSpriteNode("cube")
                        let position = CGPoint(x: x, y: y)

                        if i == 0 {
                            parentNode.position = position
                        } else {
                            node.position.x += position.x
                            node.position.y += position.y
                        }

                        node.setScale(CGFloat(scale))
                        node.name = "game_cube_\(id)_color_\(colorValue.getHexString())"
                        node.run(SKAction.colorize(with: colorValue, colorBlendFactor: 1, duration: 0), withKey: "colorize")
                        if hasPhysics {
                            node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
                            node.physicsBody?.affectedByGravity = false
                            node.physicsBody?.isDynamic = true
                            node.physicsBody?.allowsRotation = false
                            node.physicsBody?.contactTestBitMask = sContactTestCategory
                            node.physicsBody?.categoryBitMask = sGEObjectCategory
                        }
                        parentNode.addChild(node)
                        nodes.insert(positionString)
                    }
                }
            }
        } else {
            print(mData["scale"].error ?? "")
        }

        return parentNode
    }
}
