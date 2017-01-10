//
//  AppDelegate.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-08.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        let window = NSApp.windows.first!
        window.titleVisibility = .hidden
        window.styleMask.formUnion(.fullSizeContentView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

