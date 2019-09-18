//
//  Updater.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa
import Semver

private let gitHubPath = "ddddxxx/LyricsX"
private let url = URL(string: "https://api.github.com/repos/\(gitHubPath)/releases/latest")!

var remoteVersion: Semver? {
    do {
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(GitHubResponse.self, from: data)
        var tag = response.tag_name
        guard !response.draft else { return nil }
        if tag.hasPrefix("v") {
            tag.removeFirst()
        }
        return Semver(tag)
    } catch {
        log("failed to read remote varsion: \(error)")
        return nil
    }
}

var localVersion: Semver {
    let info = Bundle.main.infoDictionary!
    // swiftlint:disable:next force_cast
    let shortVersion = info["CFBundleShortVersionString"] as! String
    return Semver(shortVersion)!
}

#if IS_FOR_MAS
    
    func checkForMASReview(force: Bool = false) {
        if let buildTime = Bundle.main.infoDictionary?["LX_BUILD_TIME"] as? Double {
            let dt = Date().timeIntervalSince1970 - buildTime
            if dt > masReviewPeriodLimit {
                defaults[.isInMASReview] = false
                return
            }
        }
        guard force || (defaults[.isInMASReview] == nil) else {
            return
        }
        DispatchQueue.global().async {
            let local = localVersion
            guard let remote = remoteVersion else {
                return
            }
            defaults[.isInMASReview] = false
            //            defaults[.isInMASReview] = local > remote
        }
    }
    
#endif

extension Semver {
    
    var isPrerelease: Bool {
        return !prerelease.isEmpty
    }
}

struct GitHubResponse: Decodable {
    // swiftlint:disable:next identifier_name
    let tag_name: String
    let draft: Bool
    let prerelease: Bool
    
    /*
    let url: URL
    let assets_url: URL
    let upload_url: URL?
    let html_url: URL
    let id: Int
    let target_commitish: String
    let name: String
    let author: Author
    let created_at: Date
    let published_at: Date
    let tarball_url: URL?
    let zipball_url: URL?
    let body: String
     */
    
    // let assets: [Any]
    
    struct Author: Decodable {
        /*
        let login: String
        let id: Int
        let avatar_url: URL?
        let gravatar_id: String
        let url: URL?
        let html_url: URL?
        let followers_url: URL?
        let following_url: URL?
        let gists_url: URL?
        let starred_url: URL?
        let subscriptions_url: URL?
        let organizations_url: URL?
        let repos_url: URL?
        let events_url: URL?
        let received_events_url: URL?
        let type: String
        let site_admin: Bool
         */
    }
}
