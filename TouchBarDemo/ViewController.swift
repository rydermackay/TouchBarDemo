//
//  ViewController.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-08.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var canvasView: CanvasView {
        return view as! CanvasView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvasView.canvasViewController = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    enum ShapeTag: Int {
        case triangle = 101
        case rectangle = 102
        case oval = 103
        
        var shapeClass: BaseShape.Type {
            switch self {
            case .triangle:
                return Triangle.self
            case .rectangle:
                return Rect.self
            case .oval:
                return Oval.self
            }
        }
        
        init?(sender: AnyObject) {
            if let popUpButton = sender as? NSPopUpButton { // apparently NSButton also implements -selectedTag >_>
                self.init(rawValue: popUpButton.selectedTag())
            } else if sender.responds(to: #selector(getter: NSView.tag)) {
                self.init(rawValue: sender.tag)
            } else {
                return nil
            }
        }
    }
    
    @IBOutlet weak var addShapePopover: NSPopoverTouchBarItem?
    
    @IBAction func addShape(_ sender: AnyObject?) {
        
        let ShapeClass = sender.flatMap(ShapeTag.init(sender:))?.shapeClass ?? Triangle.self // lol
        
        let shape = ShapeClass.init(position: CGPoint(x: canvasView.bounds.midX, y: canvasView.bounds.midY),
                                    size: CGSize(width: 100, height: 100))
        canvasView.addShape(shape)
        
        addShapePopover?.dismissPopover(self)
    }

    
    func canvasView(_ canvasView: CanvasView, didSelectShape selectedShape: BaseShape?) {
        selection = selectedShape
    }
    
    dynamic var selection: BaseShape?
}

