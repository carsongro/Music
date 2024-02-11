//
//  BrowseSearchView.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

struct ContentView: View {
    
    @State private var showingFullScreenPlayer = false
    
    var body: some View {
        TabView {
            Group {
                SearchNavigationStack()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                
                LibraryNavigationStack()
                    .tabItem { Label("Library", systemImage: "music.note.list") }
            }
            .safeAreaInset(edge: .bottom) {
                if MusicPlayerManager.shared.isPlaybackQueueSet {
                    PlayerTray()
                        .onTapGesture {
                            showingFullScreenPlayer = true
                        }
                }
            }
            .sheet(isPresented: $showingFullScreenPlayer) {
                PlayerView()
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    ContentView()
}
