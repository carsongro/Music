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
                    ArtworkImage(artwork, width: animatedIsPlaying ? 330 : 250)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 8)
                }
            }
            .frame(height: 330)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
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
            }
            .playerSectionStyle()
            
            Section {
                playbackControls
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
                volumeControls
            }
            .playerSectionStyle()
        }
        .background(backgroundBlurImage)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .listSectionSpacing(20)
        .padding(.top, 20)
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
    
    @ViewBuilder
    private var backgroundBlurImage: some View {
        if let artwork = player.queue.currentEntry?.artwork {
            ArtworkImage(artwork, width: 1000)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 40)
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
            .transaction { transaction in
                transaction.animation = .none
            }
            
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

struct Centered: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .frame(width: 330)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func playerSectionStyle() -> some View {
        modifier(Centered())
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
