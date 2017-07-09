//
//  AppDelegate.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 03..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//

import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var mScene: GameScene = GameScene()

    // MARK: Properties
    @IBOutlet weak var viewDroppable: DroppableView!
    @IBOutlet weak var helpWindow: NSWindow!
    @IBOutlet weak var checkGrid: NSButton!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window.delegate = self
        if !Settings.sharedInstance.gridShowed {
            checkGrid.state = NSOffState
        }

        if let view = GameScene(fileNamed:"GameScene") {
            mScene = view
            mScene.scaleMode = .aspectFill
            self.skView!.presentScene(mScene)

            self.skView!.ignoresSiblingOrder = true
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
        }
        self.viewDroppable.onDrop = {[weak self] (filenames) in
            if let path = filenames.first {
                self?.openFile(path)
            }
            return
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func windowShouldClose(_ sender: Any) -> Bool {
        helpWindow.close()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func colorDidChange(_ sender: AnyObject) {
        if let cp = sender as? NSColorPanel {
            mScene.showColor(cp.color)
        }
    }

    // MARK: Actions
    @IBAction func colorPicker(_ sender: NSButton) {
        let cp = NSColorPanel.shared()
        cp.setTarget(self)
        cp.setAction(#selector(AppDelegate.colorDidChange(_:)))
        cp.makeKeyAndOrderFront(self)
        cp.isContinuous = true
        cp.hidesOnDeactivate = false
        cp.title = "Color Panel"
    }

    @IBAction func clearButtonClick(_ sender: NSButton) {
        mScene.clearNodes()
        exportButton.isEnabled = true
    }

    @IBAction func exportButtonClick(_ sender: NSButton) {
        let saveDialog = NSSavePanel()
        saveDialog.begin() { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                FileManager.default.createFile(atPath: saveDialog.url!.path, contents: Data(), attributes: nil)
                do {
                    self.mScene.save()
                    let file = try FileHandle(forWritingTo: saveDialog.url!)
                    if let data = (DataManager.sharedInstance.getData() as NSString).data(using: String.Encoding.utf8.rawValue) {
                        file.write(data)
                    }
                } catch {
                    print("error save")
                }
            }
        }
    }

    @IBAction func showHelp(_ sender: NSButton) {
        if let childWindow = window.childWindows, let index = childWindow.index(of: helpWindow), index > -1 {
            helpWindow.close()
        } else {
            textField1.allowsEditingTextAttributes = true
            textField1.isSelectable = true
            var linkString = "https://papplication.tumblr.com"
            var string = NSMutableAttributedString(string: linkString)

            string.beginEditing()
            var range = NSMakeRange(0, linkString.characters.count)
            string.addAttributes([NSLinkAttributeName: linkString, NSFontAttributeName: NSFont.systemFont(ofSize: 13.0) ], range: range)
            string.addAttribute(NSForegroundColorAttributeName, value: NSColor.blue, range: range)
            string.addAttribute(NSUnderlineStyleAttributeName, value:NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int), range: range)
            string.setAlignment(NSTextAlignment.center, range: range)
            string.endEditing()
            textField1.attributedStringValue = string

            textField2.allowsEditingTextAttributes = true
            textField2.isSelectable = true
            linkString = "https://github.com/papplication/galaxy-editor"
            string = NSMutableAttributedString(string: linkString)

            string.beginEditing()
            range = NSMakeRange(0, linkString.characters.count)
            string.addAttributes([NSLinkAttributeName: linkString, NSFontAttributeName: NSFont.systemFont(ofSize: 13.0) ], range: range)
            string.addAttribute(NSForegroundColorAttributeName, value: NSColor.blue, range: range)
            string.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int), range: range)
            string.setAlignment(NSTextAlignment.center, range: range)
            string.endEditing()
            textField2.attributedStringValue = string

            window.addChildWindow(helpWindow, ordered: NSWindowOrderingMode.above)
        }
    }

    @IBAction func loadInGameButton(_ sender: NSButton) {
        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.runModal()

        if let path = fileDialog.url?.path {
            if let node = GEObject(path: path, hasPhysics: true) {
                mScene.clearNodes()
                mScene.mNodes.append(node.getNode())
                mScene.addChild(node.getNode())
                exportButton.isEnabled = false
            }
        }
    }

    func openFile(_ path: String) {
        if !path.isEmpty {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                DataManager.sharedInstance.setData(jsonData)
                mScene.loadFromData()
                exportButton.isEnabled = true
            }
        }
    }

    @IBAction func importButtonClick(_ sender: NSButton) {
        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.runModal()
        if let path = fileDialog.url?.path {
            openFile(path)
        }
    }

    @IBAction func changeGridValue(_ sender: NSButton) {
        Settings.sharedInstance.gridShowed = sender.state == NSOnState
        mScene.showGrid(Settings.sharedInstance.gridShowed)
    }
}
