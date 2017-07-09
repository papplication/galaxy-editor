//
//  Common.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 04..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

let sGEObjectCategory: UInt32 = 0x1 << 1
let sContactTestCategory: UInt32 = 0x1 << 2

#if os(iOS)
typealias NSColor = UIColor
#endif

// Vector addition
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, factor: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * factor, y:point.y * factor)
}

func * (vector: CGVector, factor: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * factor, dy: vector.dy * factor)
}

extension CGPoint {
    // Get the length (a.k.a. magnitude) of the vector
    var length: CGFloat { return sqrt(self.x * self.x + self.y * self.y) }

    // Normalize the vector (preserve its direction, but change its magnitude to 1)
    var normalized: CGPoint { return CGPoint(x: self.x / self.length, y: self.y / self.length) }

    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }

    func radiansToPoint(_ point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y

        return atan2(deltaY, deltaX)
    }
}

public extension NSColor {
    func getHexString() -> String {
        let components = self.cgColor.components
        let red = Int(round((components?[0])! * 0xFF))
        let grn = Int(round((components?[1])! * 0xFF))
        let blu = Int(round((components?[2])! * 0xFF))
        let hexString = String(format: "#%02X%02X%02X", red, grn, blu)
        return hexString
    }
}

extension NSColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

let destroyAction = SKAction.sequence([
    SKAction.fadeOut(withDuration: 0.5),
    SKAction.removeFromParent()
    ])

func isMatchCategory(_ body: SKPhysicsBody, category: UInt32) -> Bool {
    return (body.categoryBitMask & category) == category
}

func adjustAssetOrientation(_ radians: CGFloat) -> CGFloat {
    return radians + (CGFloat.pi / 2)
}

func randomFloat(_ min: CGFloat, max: CGFloat) -> CGFloat {
    if #available(iOS 9.0, *) {
        struct RandomSourceHolder {
            static let randomSource = GKARC4RandomSource()
        }

        return CGFloat(RandomSourceHolder.randomSource.nextUniform()) * (max - min) + min
    } else {
        let rand: CGFloat = CGFloat(UInt(arc4random()) % 1000) / CGFloat(1000)

        return (rand) * (max - min) + min
    }
}

func randomInt(_ max: Int) -> Int {
    if #available(iOS 9.0, *) {
        struct RandomSourceHolder {
            static let randomSource = GKARC4RandomSource()
        }
        return RandomSourceHolder.randomSource.nextInt(upperBound: max) + 1
    } else {
        return Int(arc4random_uniform(UInt32(max))) + 1
    }
}

func randomPlusMinus(_ value: CGFloat) -> CGFloat {
    var invert: Bool
    if #available(iOS 9.0, *) {
        struct RandomSourceHolder {
            static let randomSource = GKARC4RandomSource()
        }
        invert = RandomSourceHolder.randomSource.nextBool()
    } else {
        invert = arc4random_uniform(2) == 1
    }

    return value * (invert ? -1.0 : 1.0)
}
