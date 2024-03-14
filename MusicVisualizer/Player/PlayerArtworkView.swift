//
//  PlayerArtworkView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 3/14/24.
//

import SwiftUI
import MusicKit

struct PlayerArtworkView: View {
    var artwork: Artwork
    var isLarge: Bool
    
    var body: some View {
        ArtworkImage(artwork, width: 330)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(radius: 12, y: 12)
            .frame(height: 330)
            .scaleEffect(isLarge ? 1 : 0.825)
            .animation(.bouncy, value: isLarge)
            .containerRelativeFrame(.horizontal)
    }
}
