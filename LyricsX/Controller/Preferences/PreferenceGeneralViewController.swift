//
//  PreferenceGeneralViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import MusicPlayer
import ServiceManagement

class PreferenceGeneralViewController: NSViewController {
    
    @IBOutlet weak var preferAuto: NSButton!
    @IBOutlet weak var preferiTunes: NSButton!
    @IBOutlet weak var preferSpotify: NSButton!
    @IBOutlet weak var preferVox: NSButton!
    @IBOutlet weak var preferAudirvana: NSButton!
    
    @IBOutlet weak var autoLaunchButton: NSButton!
    
    @IBOutlet weak var savingPathPopUp: NSPopUpButton!
    @IBOutlet weak var userPathMenuItem: NSMenuItem!
    
    @IBOutlet weak var loadHomonymLrcButton: NSButton!
    
    @IBOutlet weak var languagePopUp: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch defaults[.PreferredPlayerIndex] {
        case 0:
            preferiTunes.state = .on
        case 1:
            preferSpotify.state = .on
            loadHomonymLrcButton.isEnabled = false
        case 2:
            preferVox.state = .on
        case 3:
            preferAudirvana.state = .on
            loadHomonymLrcButton.isEnabled = false
        default:
            preferAuto.state = .on
            autoLaunchButton.isEnabled = false
        }
        
        if let url = defaults.lyricsCustomSavingPath {
            userPathMenuItem.title = url.lastPathComponent
            userPathMenuItem.toolTip = url.path
        } else {
            userPathMenuItem.isHidden = true
        }
        
        let localizedLan: [String] = localizations.map { lan in
            if let idx = lan.firstIndex(of: "-") {
                let script = lan[idx...].dropFirst()
                return Locale(identifier: lan).localizedString(forScriptCode: String(script))!
            } else {
                return Locale(identifier: lan).localizedString(forLanguageCode: lan)!
            }
        }
        languagePopUp.addItems(withTitles: localizedLan)
        
        if let lan = defaults[.SelectedLanguage],
            let idx = localizations.firstIndex(of: lan) {
            languagePopUp.selectItem(at: idx + 2)
        }
    }
    
    @IBAction func toggleAutoLaunchAction(_ sender: NSButton) {
        let enabled = sender.state == .on
        if !SMLoginItemSetEnabled(lyricsXHelperIdentifier as CFString, enabled) {
            log("Failed to set login item enabled")
        }
    }
    
    @IBAction func showInFinderAction(_ sender: Any) {
        let url = defaults.lyricsSavingPath().0
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func chooseSavingPathAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.beginSheetModal(for: self.view.window!) { result in
            if result == .OK {
                let url = openPanel.url!
                defaults.lyricsCustomSavingPath = url
                self.userPathMenuItem.title = url.lastPathComponent
                self.userPathMenuItem.toolTip = url.path
                self.userPathMenuItem.isHidden = false
                self.savingPathPopUp.select(self.userPathMenuItem)
            } else {
                self.savingPathPopUp.selectItem(at: 0)
            }
        }
    }
    @IBAction func chooseLanguageAction(_ sender: NSPopUpButton) {
        let selectedIdx = sender.indexOfSelectedItem
        if selectedIdx == 0 {
            defaults.remove(.SelectedLanguage)
            defaults.remove(.AppleLanguages)
        } else {
            let lan = localizations[selectedIdx - 2]
            defaults[.SelectedLanguage] = lan
            defaults[.AppleLanguages] = [lan]
        }
    }
    
    @IBAction func helpTranslateAction(_ sender: NSButton) {
        NSWorkspace.shared.open(crowdinProjectURL)
    }
    
    @IBAction func preferredPlayerAction(_ sender: NSButton) {
        defaults[.PreferredPlayerIndex] = sender.tag
        
        if sender.tag < 0 {
            autoLaunchButton.isEnabled = false
            autoLaunchButton.state = .off
            defaults[.LaunchAndQuitWithPlayer] = false
        } else {
            autoLaunchButton.isEnabled = true
        }
        
        if sender.tag == 1 || sender.tag == 3 {
            loadHomonymLrcButton.isEnabled = false
            loadHomonymLrcButton.state = .off
            defaults[.LoadLyricsBesideTrack] = false
        } else {
            loadHomonymLrcButton.isEnabled = true
        }
    }
}

private let localizations = Bundle.main.localizations.filter { $0 != "Base" }.sorted()
