//
//  TrackCell.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

/// `TrackCell` is a view to use in a SwiftUI `List` to represent a `Track`.
struct TrackCell: View {
    
    init(
        _ track: Track,
        from album: Album,
        action: @escaping () -> Void
    ) {
        self.track = track
        self.album = album
        self.action = action
    }
    
    let track: Track
    let album: Album
    let action: () -> Void
    
    private var subtitle: String {
        var subtitle = ""
        if track.artistName != album.artistName {
            subtitle = track.artistName
        }
        return subtitle
    }
    
    var body: some View {
        Button(action: action) {
            MusicItemCell(
                artwork: nil,
                title: track.title,
                subtitle: subtitle
            )
            .frame(minHeight: 50)
        }
    }
}
