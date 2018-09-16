//
//  SettingsViewController.swift
//  AnkleApp
//
//  Created by John Du on 2/11/17.
//  Copyright © 2017 John Du. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func quit(_ sender: NSButton) {
        dismissViewController(self)
    }
    
}


