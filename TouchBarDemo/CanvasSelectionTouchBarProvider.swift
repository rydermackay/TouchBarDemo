//
//  CanvasSelectionTouchBarProvider.swift
//  TouchBarDemo
//
//  Created by Ryder Mackay on 2017-01-08.
//  Copyright © 2017 Ryder Mackay. All rights reserved.
//

import Cocoa

private extension NSTouchBarItemIdentifier {
    static let opacity = NSTouchBarItemIdentifier("com.rydermackay.opacity")
    static let fillColor = NSTouchBarItemIdentifier("com.rydermackay.fillColor")
    static let strokeColor = NSTouchBarItemIdentifier("com.rydermackay.strokeColor")
    static let lineStyle = NSTouchBarItemIdentifier("com.rydermackay.lineStyle")
    static let lineWidth = NSTouchBarItemIdentifier("com.rydermackay.lineStyle.width")
    static let dashPattern = NSTouchBarItemIdentifier("com.rydermackay.lineStyle.dashPattern")
    
    // z-ordering
    static let bringToFront = NSTouchBarItemIdentifier("com.rydermackay.bringToFront")
    static let bringForward = NSTouchBarItemIdentifier("com.rydermackay.bringForward")
    static let sendBackward = NSTouchBarItemIdentifier("com.rydermackay.sendBackward")
    static let sendToBack = NSTouchBarItemIdentifier("com.rydermackay.sendToBack")
    
    // canvas: layer ordering???? background color or image?
}

private extension NSTouchBarCustomizationIdentifier {
    static let canvasSelection = NSTouchBarCustomizationIdentifier("com.rydermackay.canvasSelection")
}

class CanvasSelectionTouchBarProvider: NSObject {
    
    let controller: NSObjectController
    
    init(controller: NSObjectController) {
        self.controller = controller
        super.init()
    }
    
    fileprivate var _touchBarStorage: NSTouchBar?
    
    fileprivate func makeTouchBar() -> NSTouchBar {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .canvasSelection
        touchBar.defaultItemIdentifiers = [.opacity, .flexibleSpace, .fillColor, .strokeColor, .lineStyle]
        touchBar.customizationAllowedItemIdentifiers = [.flexibleSpace, .fixedSpaceSmall, .fixedSpaceLarge, .opacity, .fillColor, .strokeColor, .lineStyle, .bringToFront, .sendToBack, .bringForward, .sendBackward]
        return touchBar
    }
    
    fileprivate let lineStyleDataSource = LineStyleDataSource()
}

extension CanvasSelectionTouchBarProvider: NSTouchBarProvider {
    
    // if for some reason you set this object as a window delegate or otherwise place it in the NSTouchBarFinder search path
    class var automaticallyNotifiesObserversOfTouchBar: Bool {
        return false
    }
    
    var touchBar: NSTouchBar? {
        if _touchBarStorage == nil {
            willChangeValue(forKey: "touchBar")
            _touchBarStorage = makeTouchBar()
            didChangeValue(forKey: "touchBar")
        }
        return _touchBarStorage
    }
}

extension CanvasSelectionTouchBarProvider: NSTouchBarDelegate {
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.opacity:
            let opacityItem = NSSliderTouchBarItem(identifier: identifier)
            opacityItem.customizationLabel = "Opacity"
            opacityItem.minimumValueAccessory = NSSliderAccessory(image: #imageLiteral(resourceName:"TouchBarOpacityMinValue"))
            opacityItem.maximumValueAccessory = NSSliderAccessory(image: #imageLiteral(resourceName: "TouchBarOpacityMaxValue"))
            opacityItem.slider.minValue = 0
            opacityItem.slider.maxValue = 1
            opacityItem.slider.bind(NSValueBinding, to: controller, withKeyPath: "content.opacity", options: nil)
            opacityItem.slider.widthAnchor.constraint(lessThanOrEqualToConstant: 180).isActive = true
            return opacityItem
        case NSTouchBarItemIdentifier.fillColor:
            let fillItem = NSColorPickerTouchBarItem.colorPicker(withIdentifier: identifier)
            fillItem.customizationLabel = "Fill Color"
            fillItem.target = self
            fillItem.action = #selector(takeFillColor(_:))
            return fillItem
        case NSTouchBarItemIdentifier.strokeColor:
            let strokeItem = NSColorPickerTouchBarItem.strokeColorPicker(withIdentifier: identifier)
            strokeItem.customizationLabel = "Stroke Color"
            strokeItem.target = self
            strokeItem.action = #selector(takeStrokeColor(_:))
            return strokeItem
        case NSTouchBarItemIdentifier.lineStyle:
            let lineStyleItem = NSPopoverTouchBarItem(identifier: identifier)
            lineStyleItem.customizationLabel = "Line Style"
            lineStyleItem.collapsedRepresentationImage = #imageLiteral(resourceName: "TouchBarLineWidthPopover")
            lineStyleItem.popoverTouchBar = makeLineStylePopoverTouchBar()
            lineStyleItem.pressAndHoldTouchBar = makeLineStylePressAndHoldTouchBar()
            return lineStyleItem
        case NSTouchBarItemIdentifier.bringToFront:
            return buttonItem(identifier: identifier, title: "Bring to Front", target: nil, action: #selector(CanvasView.bringToFront(_:)))
        case NSTouchBarItemIdentifier.bringForward:
            return buttonItem(identifier: identifier, title: "Bring Forward", target: nil, action: #selector(CanvasView.bringForward(_:)))
        case NSTouchBarItemIdentifier.sendBackward:
            return buttonItem(identifier: identifier, title: "Send Backward", target: nil, action: #selector(CanvasView.sendBackward(_:)))
        case NSTouchBarItemIdentifier.sendToBack:
            return buttonItem(identifier: identifier, title: "Send to Back", target: nil, action: #selector(CanvasView.sendToBack(_:)))
        default:
            return nil
        }
    }
    
    private func buttonItem(identifier: NSTouchBarItemIdentifier, title: String, target: Any?, action: Selector) -> NSTouchBarItem {
        let item = NSCustomTouchBarItem(identifier: identifier)
        item.view = NSButton(title: title, target: target, action: action)
        item.customizationLabel = title
        return item
    }
    
    // how to make a non-customizable Touch Bar up front without delegation
    private func makeLineStylePopoverTouchBar() -> NSTouchBar {
        
        
        let lineWidthItem = makeLineWidthSliderTouchBarItem()
        
        // NSScrubber for line styles
        
        let scrubber = NSScrubber()
        scrubber.scrubberLayout = NSScrubberProportionalLayout(numberOfVisibleItems: LineStyle.allStyles.count)
        scrubber.backgroundColor = .controlColor
        scrubber.selectionBackgroundStyle = .roundedBackground
        scrubber.selectedIndex = 0
        scrubber.mode = .fixed
        scrubber.showsArrowButtons = true
        
        lineStyleDataSource.scrubber = scrubber // sets dataSource, registers views
        
        let lineStyleItem = NSCustomTouchBarItem(identifier: NSTouchBarItemIdentifier("com.rydermackay.lineStyleScrubber"))
        lineStyleItem.view = scrubber
        lineStyleItem.customizationLabel = "Line Style"
        
        let touchBar = NSTouchBar()
        touchBar.defaultItemIdentifiers = [lineWidthItem.identifier, lineStyleItem.identifier]
        touchBar.templateItems = [lineWidthItem, lineStyleItem] // touch bar will find items here before asking delegate
        
        return touchBar
        
    }
    
    private func makeLineStylePressAndHoldTouchBar() -> NSTouchBar {
        
        let lineWidthItem = makeLineWidthSliderTouchBarItem()
        
        let touchBar = NSTouchBar()
        touchBar.defaultItemIdentifiers = [lineWidthItem.identifier]
        touchBar.templateItems = [lineWidthItem] // touch bar will find items here before asking delegate
        
        return touchBar
    }
    
    private func makeLineWidthSliderTouchBarItem() -> NSSliderTouchBarItem {
        let item = NSSliderTouchBarItem(identifier: .lineWidth)
        item.slider.bind(NSValueBinding, to: controller, withKeyPath: "content.lineWidth", options: nil)
        // min/max images
        item.slider.minValue = 1
        item.slider.maxValue = 10
        item.minimumValueAccessory = NSSliderAccessory(image: #imageLiteral(resourceName: "TouchBarLineWidthMinValue"))
        item.maximumValueAccessory = NSSliderAccessory(image: #imageLiteral(resourceName: "TouchBarLineWidthMaxValue"))
        item.slider.widthAnchor.constraint(lessThanOrEqualToConstant: 180).isActive = true
        item.customizationLabel = "Line Width" // even though this bar isn't customizable, this is used for accessibility
        return item
    }
}

// note: color picker touch bar items aren't compatible w/ bindings
private extension CanvasSelectionTouchBarProvider {
    @IBAction func takeFillColor(_ sender: NSColorPickerTouchBarItem) {
        controller.setValue(sender.color, forKeyPath: "content.fillColor")
    }
    
    @IBAction func takeStrokeColor(_ sender: NSColorPickerTouchBarItem) {
        controller.setValue(sender.color, forKeyPath: "content.strokeColor")
    }
}

private extension String {
    static let lineStyleImageView = "com.rydermackay.lineStyleScrubberImageViewIdentifier"
}

private class LineStyleDataSource: NSObject {
    
    var scrubber: NSScrubber? {
        didSet {
            scrubber?.dataSource = self
            scrubber?.register(NSScrubberImageItemView.self, forItemIdentifier: .lineStyleImageView)
        }
    }
}

extension LineStyleDataSource: NSScrubberDataSource {
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return LineStyle.allStyles.count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        
        let view = scrubber.makeItem(withIdentifier: .lineStyleImageView, owner: self)! as! NSScrubberImageItemView
        view.image = LineStyle.allStyles[index].image(for: .scrubber)
        view.imageView.imageScaling = .scaleProportionallyDown
        
        return view
    }
}
