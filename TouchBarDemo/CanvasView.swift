//
//  CanvasView.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-08.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

private let shapeKeyPaths = ["fillColor", "strokeColor", "lineWidth", "opacity"]
private extension UnsafeMutableRawPointer {
    static let shapeObservation = UnsafeMutableRawPointer.allocate(bytes: 0, alignedTo: 0)
}

class CanvasView: NSView {
    
    weak var canvasViewController: ViewController?
    
    private(set) var objects = [BaseShape]()
    
    @nonobjc public func addShape(_ shape: BaseShape) {
        objects.append(shape)
        selection = shape
        beginObserving(shape)
    }
    
    public func removeShape(_ shape: BaseShape) {
        if let idx = objects.index(of: shape) {
            endObserving(shape)
            objects.remove(at: idx)
        }
    }
    
    private func beginObserving(_ shape: BaseShape) {
        for keyPath in shapeKeyPaths {
            shape.addObserver(self, forKeyPath: keyPath, options: [.new], context: .shapeObservation)
        }
    }
    
    private func endObserving(_ shape: BaseShape) {
        for keyPath in shapeKeyPaths {
            shape.removeObserver(self, forKeyPath: keyPath, context: .shapeObservation)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == .shapeObservation {
            needsDisplay = true
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        
        for drawable in objects.filter({$0.frame.intersects(dirtyRect)}) {
            drawable.draw(in: self)
        }
        
        drawSelection(dirtyRect)
    }
    
    private var selectionPhase: CGFloat = 0 {
        didSet {
            setNeedsDisplay(selectionFrame)
        }
    }
    
    @objc private func tick(_ sender: Any) {
        selectionPhase += 0.1
        if selection != nil {
            perform(#selector(tick(_:)), with: sender, afterDelay: 1/60)
        }
    }
    
    private func drawSelection(_ dirtyRect: NSRect) {
        guard let selection = selection else { return }
            
        NSColor.black.setStroke()
        
        let rect = selection.frame.insetBy(dx: -4, dy: -4)
        
        let backingRect = backingAlignedRect(rect, options: .alignAllEdgesNearest)
        
        
        let selectionPath = NSBezierPath(rect: backingRect)
        selectionPath.setLineDash([5, 5], count: 2, phase: selectionPhase)
        selectionPath.lineWidth = 2
        selectionPath.stroke()
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    var selection: BaseShape? {
        didSet {
            var dirtyRect = oldValue?.frame.insetBy(dx: -8, dy: -8) ?? .null
            dirtyRect = dirtyRect.union(selectionFrame)
            setNeedsDisplay(dirtyRect)
            touchBar = nil
            tick(self)
            
            objectController.content = selection
            
            canvasViewController?.canvasView(self, didSelectShape: selection)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let pointInView = convert(event.locationInWindow, from: nil)
        
        // hit test canvas objects, adding handle overlay thingies
        
        for object in objects.reversed() {
            if object.path.contains(pointInView) {
                
                selection = object
                
//                // stupid text editing stuff
//                if event.clickCount == 2 {
//                    let editor = window!.fieldEditor(true, for: self)!
//                    editor.string = "Hello"
//                    editor.backgroundColor = nil
//                    editor.drawsBackground = false
//                    editor.frame = selectionFrame
//                    addSubview(editor)
//                    editor.selectAll(self)
//                    window!.makeFirstResponder(editor)
//                    return
//                }
                
                var lastPoint = pointInView
                var isTracking = true
                while isTracking {
                    guard let nextEvent = window?.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) else { continue }
                    
                    switch nextEvent.type {
                    case .leftMouseDragged:
                        let nextPoint = convert(nextEvent.locationInWindow, from: nil)
                        let translation = CGPoint(x: nextPoint.x - lastPoint.x, y: nextPoint.y - lastPoint.y)
                        translateSelection(by: translation)
                        lastPoint = nextPoint
                    case .leftMouseUp:
                        isTracking = false
                    default:
                        continue
                    }
                }
                
                return
            }
        }
        
        selection = nil
    }
    
    override func objectDidBeginEditing(_ editor: Any) {
        
    }
    
    override func objectDidEndEditing(_ editor: Any) {
        Swift.print("did end editing")
    }
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    override func cancelOperation(_ sender: Any?) {
        if selection != nil {
            selection = nil
        } else {
            NSBeep()
        }
    }
    
    let nudgeAmount: CGFloat = 10
    
    override func moveLeft(_ sender: Any?) {
        translateSelection(by: CGPoint(x: -nudgeAmount, y: 0))
    }
    
    override func moveRight(_ sender: Any?) {
        translateSelection(by: CGPoint(x: nudgeAmount, y: 0))
    }
    
    override func moveUp(_ sender: Any?) {
        translateSelection(by: CGPoint(x: 0, y: nudgeAmount))
    }
    
    override func moveDown(_ sender: Any?) {
        translateSelection(by: CGPoint(x: 0, y: -nudgeAmount))
    }
    
    override func deleteBackward(_ sender: Any?) {
        if let selection = selection {
            removeShape(selection)
            self.selection = nil
        } else {
            NSBeep()
        }
    }
    
    func translateSelection(by translation: CGPoint) {
        guard let selection = selection else { return }
        let originalFrame = selectionFrame
        selection.position.x += translation.x
        selection.position.y += translation.y
        let dirtyRect = originalFrame.union(selectionFrame)
        setNeedsDisplay(dirtyRect)
    }
    
    var selectionFrame: CGRect {
        return selection?.frame.insetBy(dx: -8, dy: -8) ?? .null
    }
    
    @IBAction func bringToFront(_ sender: Any) {
        
        if objects.last === selection {
            NSBeep()
            return
        }
        
        if let selection = selection {
            let idx = objects.index(where: {$0 === selection })!
            objects.remove(at: idx)
            objects.append(selection)
            needsDisplay = true
        }
    }
    
    @IBAction func bringForward(_ sender: Any) {
        
        if objects.last === selection {
            NSBeep()
            return
        }
        
        if let selection = selection {
            let idx = objects.index(where: {$0 === selection })!
            objects.remove(at: idx)
            objects.insert(selection, at: idx+1)
            needsDisplay = true
        }
    }
    
    @IBAction func sendToBack(_ sender: Any) {
        
        if objects.first === selection {
            NSBeep()
            return
        }
        
        if let selection = selection {
            let idx = objects.index(where: {$0 === selection })!
            objects.remove(at: idx)
            objects.insert(selection, at: 0)
            needsDisplay = true
        }
    }
    
    @IBAction func sendBackward(_ sender: Any) {
        if objects.first === selection {
            NSBeep()
            return
        }
        
        if let selection = selection {
            let idx = objects.index(where: {$0 === selection })!
            objects.remove(at: idx)
            objects.insert(selection, at: idx-1)
            needsDisplay = true
        }
    }
    
    lazy var objectController = NSObjectController()
    lazy var canvasSelectionTouchBarProvider: CanvasSelectionTouchBarProvider = { [unowned self] in
        return CanvasSelectionTouchBarProvider(controller: self.objectController)
    }()
    
    override func makeTouchBar() -> NSTouchBar? {
        guard selection != nil else { return nil }
        return canvasSelectionTouchBarProvider.touchBar
    }
}


