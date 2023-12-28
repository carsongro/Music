//
//  PlayerView.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

struct PlayerView: View {
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private let player = ApplicationMusicPlayer.shared
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            gradient
            
            VStack {
                if let artwork = player.queue.currentEntry?.artwork {
                    ArtworkImage(artwork, width: 200)
                        .matchedGeometryEffect(id: artwork.hashValue, in: namespace)
                }
                
                HStack {
                    Text(player.queue.currentEntry?.title ?? "Nothing is playing")
                        .lineLimit(1)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Button {
                    MusicPlayerManager.shared.handlePlayPause()
                } label: {
                    Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
                .padding(.trailing, 20)
                .transaction { transaction in
                    transaction.animation = .none
                }
            }
            .padding()
        }
        .ignoresSafeArea()
    }
    
    private var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: (130.0 / 255.0), green: (109.0 / 255.0), blue: (204.0 / 255.0)),
                Color(red: (130.0 / 255.0), green: (130.0 / 255.0), blue: (211.0 / 255.0)),
                Color(red: (131.0 / 255.0), green: (160.0 / 255.0), blue: (218.0 / 255.0))
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .flipsForRightToLeftLayoutDirection(false)
        .ignoresSafeArea()
    }
}

#Preview {
    PlayerView()
}
