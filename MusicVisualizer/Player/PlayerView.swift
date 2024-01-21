//
//  PlayerView.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MediaPlayer
import MusicKit
import SwiftUI

struct PlayerView: View {
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private let player = ApplicationMusicPlayer.shared
    @State private var animatedIsPlaying = ApplicationMusicPlayer.shared.state.playbackStatus == .playing
    
    var body: some View {
        List {
            Section {
                if let artwork = player.queue.currentEntry?.artwork {
                    ArtworkImage(artwork, width: animatedIsPlaying ? 320 : 250)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            
            Section {
                HStack {
                    Text(player.queue.currentEntry?.title ?? "Nothing is playing")
                        .lineLimit(1)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .frame(width: 320)
            .frame(maxWidth: .infinity)
            
            Section {
                Button {
                    MusicPlayerManager.shared.handlePlayPause()
                } label: {
                    Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 30, height: 30)
                .frame(maxWidth: .infinity)
                .transaction { transaction in
                    transaction.animation = .none
                }
            }
            .listRowSeparator(.hidden)
            
            Section {
                HStack(alignment: .center) {
                    Image(systemName: "speaker.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                        .frame(width: 15, height: 15)
                    
                    MusicVolumeSlider() // For some reason UIViewRepresentable get rid of the presentationDragIndicator
                        .frame(alignment: .center)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                }
            }
            .listRowSeparator(.hidden)
            .frame(width: 320)
            .frame(maxWidth: .infinity)
        }
        .listStyle(.plain)
        .listSectionSpacing(20)
        .padding(.vertical)
        .onChange(of: playerState.playbackStatus) { oldValue, newValue in
            withAnimation(.bouncy) {
                if newValue == .playing {
                    animatedIsPlaying = true
                } else {
                    animatedIsPlaying = false
                }
            }
        }
    }
}

struct MusicVolumeSlider: UIViewRepresentable {
    class VolumeSlider: MPVolumeView {
        override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
            var newBounds = super.volumeSliderRect(forBounds: bounds)
            newBounds.origin.y = bounds.origin.y
            newBounds.size.height = bounds.size.height
            return newBounds
        }
        
        override func volumeThumbRect(
            forBounds bounds: CGRect,
            volumeSliderRect rect: CGRect,
            value: Float
        ) -> CGRect {
            var newBounds = super.volumeThumbRect(forBounds: bounds, volumeSliderRect: rect, value: value)
            newBounds.origin.y = bounds.origin.y
            newBounds.size.height = bounds.size.height
            return newBounds
        }
    }
    
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = VolumeSlider(frame: .zero)
        volumeView.setVolumeThumbImage(UIImage(), for: .normal)
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        
    }
}

#Preview {
    PlayerView()
}
