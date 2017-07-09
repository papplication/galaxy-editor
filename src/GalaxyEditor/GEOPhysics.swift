//
//  GEOPhysics.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 05. 15..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import SpriteKit

class GEOPhysics {
    static func doPhysics(_ reasonBody: SKSpriteNode, sufferBody: SKSpriteNode, contactNormal: CGVector) {
        let contactNormal = contactNormal * -1
        if let body = sufferBody.physicsBody {
            body.affectedByGravity = true
            body.applyImpulse(contactNormal)
            body.contactTestBitMask = sContactTestCategory | sGEObjectCategory
        }
        reasonBody.physicsBody?.contactTestBitMask = sContactTestCategory | sGEObjectCategory
        var sufferPosition = sufferBody.position
        if let parent = sufferBody.parent {
            sufferPosition = parent.position + sufferPosition
        }

        let duration = Double(randomFloat(1.3, max: 3.0))
        let physicsAction = SKAction.sequence([
            SKAction.speed(to: 0.5, duration: 0),
            SKAction.scale(to: 0.0, duration: Double(randomFloat(0.5, max: 2.0))),
            SKAction.removeFromParent()
            ])
        sufferBody.run(physicsAction)
        sufferBody.run(SKAction.speed(to: 1, duration: duration/2))

        let angle = adjustAssetOrientation(reasonBody.position.radiansToPoint(sufferPosition))
        sufferBody.run(SKAction.rotate(toAngle: angle, duration: Double(randomFloat(0.3, max: 1.0)), shortestUnitArc: true))
    }

    static func didBeginContact(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        if let secondSpriteNode = secondBody.node as? SKSpriteNode, let firstSpriteNode = firstBody.node as? SKSpriteNode {
            if (isMatchCategory(firstBody, category: sGEObjectCategory) && isMatchCategory(secondBody, category: sContactTestCategory)) {
                doPhysics(secondSpriteNode, sufferBody: firstSpriteNode, contactNormal: contact.contactNormal)
            } else if (isMatchCategory(secondBody, category: sGEObjectCategory) && isMatchCategory(firstBody, category: sContactTestCategory)) {
                doPhysics(firstSpriteNode, sufferBody: secondSpriteNode, contactNormal: contact.contactNormal)
            } else if (isMatchCategory(firstBody, category: sGEObjectCategory) && isMatchCategory(secondBody, category: sGEObjectCategory)) {
                doPhysics(secondSpriteNode, sufferBody: firstSpriteNode, contactNormal: contact.contactNormal)
            }
        }
    }
}
