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
    
    var body: some View {
        @Bindable var playerManager = MusicPlayerManager.shared

        VStack(spacing: 30) {
            if let artwork = player.queue.currentEntry?.artwork {
                ArtworkImage(artwork, width: playerState.playbackStatus == .playing ? 330 : 250)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: playerState.playbackStatus == .playing ? 12 : 6, y: playerState.playbackStatus == .playing ? 12 : 6)
                    .frame(height: 330)
                    .animation(.bouncy, value: playerState.playbackStatus == .playing)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(player.queue.currentEntry?.title ?? "Nothing is playing")
                        .lineLimit(1)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(player.queue.currentEntry?.subtitle ?? "")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                
                Spacer()
            }
            
            if let duration = playerManager.currentDuration {
                PlaybackTimeControlView(
                    playbackTime: $playerManager.currentPlaybackTime,
                    duration: duration,
                    isPlaying: playerState.playbackStatus == .playing
                ) { newTime in
                    MusicPlayerManager.shared.setPlaybackTime(newTime)
                }
            }
            
            playbackControls
            
            volumeControls
            
            Spacer()
        }
        .frame(width: 330)
        .background(backgroundBlurImage)
        .padding(.top, 30)
    }
    
    @ViewBuilder
    private var backgroundBlurImage: some View {
        if let artwork = player.queue.currentEntry?.artwork {
            ArtworkImage(artwork, width: 1000)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 80)
        }
    }
    
    private var volumeControls: some View {
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
        .frame(height: 44)
    }
    
    private var playbackControls: some View {
        HStack {
            Button {
                MusicPlayerManager.shared.handleSkipToPrevious()
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .buttonStyle(.plain)
            .frame(width: 40, height: 40)
            .frame(maxWidth: .infinity)
            
            Button {
                MusicPlayerManager.shared.handlePlayPause()
            } label: {
                Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .buttonStyle(.plain)
            .frame(width: 38, height: 38)
            .frame(maxWidth: .infinity)
            
            Button {
                MusicPlayerManager.shared.handleSkipToNext()
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .buttonStyle(.plain)
            .frame(width: 40, height: 40)
            .frame(maxWidth: .infinity)
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
