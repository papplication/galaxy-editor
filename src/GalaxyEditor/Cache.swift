//
//  Cache.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 10..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import SpriteKit

class Cache: NSObject {
    var items: Dictionary<String, Int> = Dictionary<String, Int>()
    var nodes: Dictionary<String, SKSpriteNode> = Dictionary<String, SKSpriteNode>()
    var textures: Dictionary<String, SKTexture> = Dictionary<String, SKTexture>()
    var actions: Dictionary<String, SKAction> = Dictionary<String, SKAction>()
    var emitters: Dictionary<String, SKEmitterNode> = Dictionary<String, SKEmitterNode>()
    var sounds: Dictionary<String, SKAction> = Dictionary<String, SKAction>()
    var timer: Timer = Timer()
    let limit: Int = 300
    var cacheIsValid: Bool = true

    class var sharedInstance: Cache {
        struct Static {
            static let instance = Cache()
        }
        return Static.instance
    }

    override init() {
        super.init()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(Cache.calculateUsage), userInfo: nil, repeats: true)
    }

    func calculateUsage() {
        let keyTmp = items.keys
        for key in keyTmp {
            if let usage = items[key] {
                if usage > limit {
                    if let index = nodes.index(forKey: key) {
                        nodes.remove(at: index)
                    }
                    if let index = actions.index(forKey: key) {
                        actions.remove(at: index)
                    }
                    if let index = emitters.index(forKey: key) {
                        emitters.remove(at: index)
                    }
                    if let index = items.index(forKey: key) {
                        items.remove(at: index)
                    }
                    if let index = textures.index(forKey: key) {
                        textures.remove(at: index)
                    }
                } else {
                    items[key] = usage + 5
                }
            }
        }
    }

    func pause() {
        timer.invalidate()
    }

    func resume() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(Cache.calculateUsage), userInfo: nil, repeats: true)
    }

    func clearCache() {
        cacheIsValid = false
        nodes.removeAll(keepingCapacity: false)
        actions.removeAll(keepingCapacity: false)
        emitters.removeAll(keepingCapacity: false)
        textures.removeAll(keepingCapacity: false)
        sounds.removeAll(keepingCapacity: false)
        cacheIsValid = true
    }

    func getSound(_ name: String) -> SKAction? {
        if !cacheIsValid {
            return SKAction.playSoundFileNamed(name, waitForCompletion: false)
        }
        if sounds.index(forKey: name) == nil {
            self.sounds[name] = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        }
        items[name] = 0
        return sounds[name]
    }

    func getSKSpriteNode(_ name: String) -> SKSpriteNode {
        if !cacheIsValid {
            return SKSpriteNode(imageNamed: name)
        }
        if nodes.index(forKey: name) == nil {
            self.nodes[name] = SKSpriteNode(imageNamed: name)
        }
        items[name] = 0
        if let node = nodes[name]?.copy() as? SKSpriteNode {
            return node
        }
        return SKSpriteNode()
    }

    func getSKTexture(_ imageNamed: String) -> SKTexture {
        if !cacheIsValid {
            return SKTexture(imageNamed: imageNamed)
        }
        if textures.index(forKey: imageNamed) == nil {
            self.textures[imageNamed] = SKTexture(imageNamed: imageNamed)
        }
        items[imageNamed] = 0
        if let texture = textures[imageNamed] {
            return texture
        }
        return SKTexture()
    }

    func getSKEmitterNode(_ fileNamed: String) -> SKEmitterNode? {
        if !cacheIsValid {
            return SKEmitterNode(fileNamed: fileNamed)
        }
        if emitters.index(forKey: fileNamed) == nil {
            self.emitters[fileNamed] = SKEmitterNode(fileNamed: fileNamed)
        }
        items[fileNamed] = 0
        return emitters[fileNamed]?.copy() as? SKEmitterNode
    }

    func getAction(_ name: String) -> SKAction? {
        if !cacheIsValid {
            return nil
        }
        items[name] = 0
        return actions[name]
    }

    func setAction(_ name: String, action: SKAction) {
        if !cacheIsValid {
            return
        }
        items[name] = 0
        actions[name] = action
    }
}
