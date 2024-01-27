//
//  PlaybackTimeControlView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/27/24.
//

import SwiftUI

extension TimeInterval {
    var minutesAndSeconds: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        var formattedString = formatter.string(from: self) ?? ""
        if formattedString.first == "0" {
            formattedString.removeFirst()
        }
        
        return formattedString
    }
}

struct PlaybackTimeControlView: View {
    static let refreshRate: Double = 1.0
    
    @Binding var playbackTime: TimeInterval
    var duration: TimeInterval
    var isPlaying: Bool
    var setPlayback: (TimeInterval) -> Void
    
    init(
        playbackTime: Binding<TimeInterval>,
        duration: TimeInterval,
        isPlaying: Bool,
        _ setPlayback: @escaping (TimeInterval) -> Void
    ) {
        self._playbackTime = playbackTime
        self.duration = duration
        self.isPlaying = isPlaying
        self.setPlayback = setPlayback
    }
    
    let timer = Timer.publish(every: refreshRate, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Slider(value: $playbackTime, in: 0...duration) { isEditing in
                if !isEditing {
                    setPlayback(playbackTime)
                }
            }
            
            HStack {
                Text(playbackTime.minutesAndSeconds)
                
                Spacer()
                
                Text("-" + (duration - playbackTime).minutesAndSeconds)
            }
            .foregroundStyle(.secondary)
            .font(.subheadline.monospacedDigit())
            .fontWeight(.semibold)
            .transaction { transaction in
                transaction.animation = .none
            }
        }
        .onReceive(timer) { _ in
            if isPlaying {
                withAnimation(.linear(duration: PlaybackTimeControlView.refreshRate)) {
                    playbackTime += PlaybackTimeControlView.refreshRate
                }
            }
        }
    }
}

#Preview {
    PlaybackTimeControlView(
        playbackTime: .constant(100),
        duration: 250,
        isPlaying: false
    ) { _ in
        
    }
}
