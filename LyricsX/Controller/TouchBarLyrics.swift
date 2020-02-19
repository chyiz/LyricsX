//
//  TouchBarLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import DFRPrivate
import LyricsCore
import OpenCC

@available(OSX 10.12.2, *)
class TouchBarSystemModalController: NSObject, NSTouchBarDelegate {
    
    var touchBar: NSTouchBar?
    var systemTrayItem: NSCustomTouchBarItem?
    
    override init() {
        super.init()
        loadTouchBar()
        touchBar?.delegate = self
        touchBarDidLoad()
        showInControlStrip()
    }
    
    /// customization point
    func loadTouchBar() {
        if touchBar == nil {
            touchBar = NSTouchBar()
        }
    }
    
    /// customization point
    func touchBarDidLoad() {
        
    }
    
    @objc func showInControlStrip() {
        NSTouchBar.setSystemModalShowsCloseBoxWhenFrontMost(false)
        systemTrayItem?.addToSystemTray()
        systemTrayItem?.setControlStripPresence(true)
    }
    
    @objc func removeFromControlStrip() {
        dismiss()
        systemTrayItem?.setControlStripPresence(false)
        systemTrayItem?.removeFromSystemTray()
    }
    
    @objc func present() {
        if let touchBar = self.touchBar, let systemTrayItem = self.systemTrayItem {
            touchBar.presentAsSystemModal(for: systemTrayItem)
        }
    }
    
    @objc func minimize() {
        touchBar?.minimizeSystemModal()
    }
    
    @objc func dismiss() {
        touchBar?.dismissSystemModal()
    }
}

@available(OSX 10.12.2, *)
class TouchBarLyrics: TouchBarSystemModalController {
    
    private var lyricsItem = TouchBarLyricsItem(identifier: .lyrics)
    
    override func touchBarDidLoad() {
        touchBar?.defaultItemIdentifiers = [.currentArtwork, .fixedSpaceSmall, .playbackControl, .fixedSpaceSmall, .lyrics, .flexibleSpace, .otherItemsProxy]
        touchBar?.customizationIdentifier = .main
        touchBar?.customizationAllowedItemIdentifiers = [.currentArtwork, .playbackControl, .lyrics, .fixedSpaceSmall, .fixedSpaceLarge, .flexibleSpace, .otherItemsProxy]
        
        systemTrayItem = NSCustomTouchBarItem(identifier: .systemTrayItem)
        systemTrayItem?.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(present))
        
        lyricsItem.bind(\.progressColor, withUnmatchedDefaultName: .DesktopLyricsProgressColor)
        
        self.observeNotification(name: NSApplication.willBecomeActiveNotification) { [weak self] _ in
            guard let self = self else { return }
            self.removeFromControlStrip()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                NSApp.touchBar = self.touchBar
            }
        }
        
        self.observeNotification(name: NSApplication.didResignActiveNotification) { [weak self] _ in
            guard let self = self else { return }
            NSApp.touchBar = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.showInControlStrip()
            }
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .lyrics:
            return lyricsItem
        case .playbackControl:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.viewController = TouchBarPlaybackControlViewController()
            item.customizationLabel = "Playback Control"
            return item
        case .currentArtwork:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.viewController = TouchBarArtworkViewController()
            item.customizationLabel = "Artwork"
            return item
        default:
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
private extension NSTouchBarItem.Identifier {
    
    static let lyrics = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.lyrics")
    static let currentArtwork = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.currentArtwork")
    static let playbackControl = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.playbackControl")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.systemTrayItem")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let main = NSTouchBar.CustomizationIdentifier("ddddxxx.LyricsX.touchBar.customization.main")
}
