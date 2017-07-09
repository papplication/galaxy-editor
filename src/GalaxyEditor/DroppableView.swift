//
//  DroppableView.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 21..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Foundation
import Cocoa

class DroppableView: NSView {
    var onDrop: (([String]) -> Void)?

    // MARK: - Initialization
    ////////////////////////////////////////////////////////////////////////////

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        self.register(forDraggedTypes: [NSFilenamesPboardType])
    }

    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Drag & Drop support
    ////////////////////////////////////////////////////////////////////////////

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pBoard = sender.draggingPasteboard()
        if let files = pBoard.propertyList(forType: NSFilenamesPboardType) as? [String] {
            self.onDrop?(files)
        }
        return true
    }
}
