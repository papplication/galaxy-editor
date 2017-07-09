//
//  GEObject.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 10..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import SpriteKit

class GEObject {

	// MARK: - Initialization
	////////////////////////////////////////////////////////////////////////////

    fileprivate let mNode: SKSpriteNode

    init?(path: String, hasPhysics: Bool) {
        if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            DataManager.sharedInstance.setData(jsonData)
            mNode = DataManager.sharedInstance.getNode(hasPhysics)
        } else {
            return nil
        }
    }

    func getNode() -> SKSpriteNode {
        return mNode
    }
}
