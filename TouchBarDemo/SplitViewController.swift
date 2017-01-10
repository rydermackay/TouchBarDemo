//
//  SplitViewController.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-09.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    
    var canvasViewController: ViewController!
    var inspectorViewController: InspectorViewController!
    
    @IBOutlet var addShapePopoverTouchBarItem: NSPopoverTouchBarItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        canvasViewController = childViewControllers[0] as! ViewController
        inspectorViewController = childViewControllers[1] as! InspectorViewController
        
        inspectorViewController.bind("representedObject", to: canvasViewController, withKeyPath: "selection", options: nil)
    }
    
    @IBAction func addShapePopoverAction(_ sender: AnyObject?) {
        addShapePopoverTouchBarItem?.dismissPopover(self)
        canvasViewController.addShape(sender)
    }
    
    // redirect nil-targeted actions downward
    override func supplementalTarget(forAction action: Selector, sender: Any?) -> Any? {
        if canvasViewController.responds(to: action) {
            return canvasViewController
        } else {
            return super.supplementalTarget(forAction: action, sender: sender)
        }
    }
}
