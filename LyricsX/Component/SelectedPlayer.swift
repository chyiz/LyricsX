//
//  AppController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import MusicPlayer
import GenericID
import CombineX

extension MusicPlayers {
    
    final class Selected: Delegate {
        
        static let shared = MusicPlayers.Selected()
        
        private var defaultsObservation: DefaultsObservation?
        
        var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        override init() {
            super.init()
            selectPlayer()
            scheduleManualUpdate()
            defaultsObservation = defaults.observe(keys: [.PreferredPlayerIndex, .UseSystemWideNowPlaying]) { [weak self] in
                self?.selectPlayer()
            }
        }
        
        private func selectPlayer() {
            let idx = defaults[.PreferredPlayerIndex]
            if idx == -1 {
                if defaults[.UseSystemWideNowPlaying] {
                    designatedPlayer = MusicPlayers.SystemNowPlaying()
                } else {
                    let players = MusicPlayerName.scriptableCases.compactMap(MusicPlayers.Scriptable.init)
                    designatedPlayer = MusicPlayers.NowPlaying(players: players)
                }
            } else {
                designatedPlayer = MusicPlayerName(index: idx).flatMap(MusicPlayers.Scriptable.init)
            }
        }
        
        private var scheduleCanceller: Cancellable?
        func scheduleManualUpdate() {
            scheduleCanceller?.cancel()
            guard manualUpdateInterval > 0 else { return }
            let q = DispatchQueue.global().cx
            let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                self.designatedPlayer?.updatePlayerState()
            }
        }
    }
}
