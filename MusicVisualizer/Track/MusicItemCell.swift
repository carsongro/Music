//
//  MusicItemCell.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

/// `MusicItemCell` is a view to use in a SwiftUI `List` to represent a `MusicItem`.
struct MusicItemCell: View {
    
    let artwork: Artwork?
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            if let artwork {
                VStack {
                    Spacer()
                    ArtworkImage(artwork, width: 56)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.top, -4.0)
                }
            }
            
            Spacer()
        }
    }
}
