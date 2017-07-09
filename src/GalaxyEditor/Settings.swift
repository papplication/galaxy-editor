//
//  Settings.swift
//  GalaxyEditor
//
//  Created by Papp Oliver on 2016. 04. 03..
//  Copyright © 2015-2016. P'application Studio. All rights reserved.
//
import Foundation

class Settings {

    var gridShowed: Bool = false {
        didSet {
            UserDefaults.standard.set(gridShowed, forKey: "gridShowed")
        }
    }

    class var sharedInstance: Settings {
        struct Static {
            static let instance = Settings()
        }
        return Static.instance
    }

    init() {
        loadettings()
    }

    func loadettings() {
        let userDefaults: UserDefaults = UserDefaults.standard
        if let value = userDefaults.object(forKey: "gridShowed") as? Bool {
            gridShowed = value
        }
    }
}
