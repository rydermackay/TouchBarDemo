//
//  Shapes.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-08.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

protocol Drawable {
    func draw(in view: CanvasView)
}

protocol Shape: Drawable {
    var position: CGPoint { get }
    var size: CGSize { get }
    var path: NSBezierPath { get }
    
    var fillColor: NSColor? { get }
    var strokeColor: NSColor? { get }
    var lineWidth: CGFloat { get }
    var opacity: CGFloat { get }
}

extension Shape {
    var frame: CGRect {
        let origin = CGPoint(x: position.x - size.width / 2,
                             y: position.y - size.height / 2)
        return CGRect(origin: origin, size: size).insetBy(dx: -lineWidth / 2, dy: -lineWidth / 2)
    }
    
    func draw(in view: CanvasView) {
        
        NSGraphicsContext.saveGraphicsState()
        
        let ctx = NSGraphicsContext.current()!.cgContext
        ctx.setAlpha(opacity)
        
        if let fillColor = fillColor {
            fillColor.setFill()
            path.fill()
        }
        if let strokeColor = strokeColor {
            strokeColor.setStroke()
            path.lineWidth = lineWidth
            path.stroke()
        }
        
        NSGraphicsContext.restoreGraphicsState()
    }
}

class BaseShape: NSObject, Shape {
    required init(position: CGPoint, size: CGSize) {
        self.position = position
        self.size = size
    }
    
    dynamic var position: CGPoint {
        didSet {
            _path = nil
        }
    }
    
    dynamic var size: CGSize {
        didSet {
            _path = nil
        }
    }
    
    dynamic var fillColor: NSColor? = .red
    dynamic var strokeColor: NSColor? = .black
    dynamic var lineWidth: CGFloat = 2
    dynamic var opacity: CGFloat = 1
    
    var path: NSBezierPath { return _path }
    
    // apparently can't satisfy protocol requirement w/ lazy var
    private lazy var _path: NSBezierPath! = self.makePath()
    
    func makePath() -> NSBezierPath {
        fatalError("BaseShape is an abstract class; sosumi!!")
    }
}

class Triangle: BaseShape {
    override func makePath() -> NSBezierPath {
        let bottomLeft = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        let bottomRight = CGPoint(x: position.x + size.width / 2, y: position.y - size.height / 2)
        let topMiddle = CGPoint(x: position.x, y: position.y + size.height / 2)
        
        let path = NSBezierPath()
        path.move(to: bottomLeft)
        path.line(to: bottomRight)
        path.line(to: topMiddle)
        path.close()
        
        return path
    }
}

class Oval: BaseShape {
    override func makePath() -> NSBezierPath {
        return NSBezierPath(ovalIn: frame)
    }
}

class Rect: BaseShape {
    override func makePath() -> NSBezierPath {
        return NSBezierPath(rect: frame)
    }
}

class LineStyle: NSObject {
    
    enum DisplayStyle {
        case menu
        case scrubber
    }
    
    private let dashPattern: [CGFloat]
    
    private init(dashPattern: [CGFloat]) {
        self.dashPattern = dashPattern
        super.init()
    }
    
    class var allStyles: [LineStyle] {
        return [
            LineStyle(dashPattern: []),
            LineStyle(dashPattern: [1, 1]),
            LineStyle(dashPattern: [4, 4]),
            LineStyle(dashPattern: [3, 2, 1, 2, 3])
        ]
    }
    
    func apply(to path: NSBezierPath) {
        path.setLineDash(dashPattern.map{$0 * path.lineWidth}, count: dashPattern.count, phase: 0)
    }
    
    func image(for displayStyle: DisplayStyle) -> NSImage {
        
        let path = NSBezierPath()
        path.move(to: .zero)
        
        switch displayStyle {
        case .menu:
            path.line(to: NSPoint(x: 0, y: 50))
        case .scrubber:
            path.line(to: NSPoint(x: 18, y: 18))
        }
        
        path.lineWidth = 2
        apply(to: path)
        
        let image = NSImage(size: path.bounds.size, flipped: false) { rect in
            NSColor.white.setStroke()
            path.stroke()
            return true
        }
        
        image.isTemplate = true
        
        return image
    }
}
