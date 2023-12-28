//
//  PlayerTray.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

struct PlayerTray: View {
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private let player = ApplicationMusicPlayer.shared
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            HStack {
                Group {
                    if let artwork = player.queue.currentEntry?.artwork {
                        ArtworkImage(artwork, width: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .matchedGeometryEffect(id: artwork.hashValue, in: namespace)
                    }
                }
                .frame(minWidth: 40, minHeight: 40)
                
                Text(player.queue.currentEntry?.title ?? "Nothing is playing")
                    .lineLimit(1)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    MusicPlayerManager.shared.handlePlayPause()
                } label: {
                    Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .padding(.trailing, 20)
                .transaction { transaction in
                    transaction.animation = .none
                }
            }
            .frame(minHeight: 40)
            .padding(8)
        }
        .background {
            Rectangle()
                .foregroundStyle(Color(.secondarySystemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 8)
    }
}
