TouchBarDemo
============
This project demonstrates adding Touch Bar support to a simple Cocoa application. Examples include:

- nesting touch bars
- supporting user customization
- using standard AppKit controls, `NSSliderTouchBarItem` & `NSColorPickerTouchBarItem`
- using `NSScrubber` to show a list
- using popovers & press-and-hold gesture


Also, different ways to create `NSTouchBar` instances:

- lazily, by implementing `-makeTouchBar` and `NSTouchBarDelegate`
- up front, using template items
- in Interface Builder

Requirements
------------
Xcode 8.2 and macOS 10.12.2 or later.

References
----------
- [Apple Developer: Mac Apps + Touch Bar](https://developer.apple.com/macos/touch-bar/)
- [macOS Human Interface Guidelines: Touch Bar](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/OSXHIGuidelines/AbouttheTouchBar.html#//apple_ref/doc/uid/20000957-CH104-SW1)
- [NSTouchBar API Reference](https://developer.apple.com/reference/appkit/nstouchbar)
- [NSTouchBarCatalog](https://developer.apple.com/library/content/samplecode/NSTouchBarCatalog/Introduction/Intro.html#//apple_ref/doc/uid/TP40017550) (Swift & Objective-C)
- [ToolbarSample](https://developer.apple.com/library/content/samplecode/ToolbarSample/Introduction/Intro.html) (Swift)

Contact
-------
Ryder Mackay    
Twitter: [@rydermackay](https://twitter.com/rydermackay)    
http://analogkid.ca    
