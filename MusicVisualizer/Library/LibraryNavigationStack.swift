//
//  LibraryNavigationStack.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/24/24.
//

import SwiftUI
import MusicKit

struct LibraryNavigationStack: View {
    @State private var libraryModel = LibraryModel.shared
    
    var body: some View {
        @Bindable var libraryModel = libraryModel
        
        NavigationStack {
            LibraryPlaylistList()
                .environment(libraryModel)
                .navigationTitle("Library")
                .musicNavigationDestinations()
                .searchable(text: $libraryModel.searchText)
                .onChange(of: WelcomeView.PresentationCoordinator.shared.musicAuthorizationStatus) { _, _ in
                    libraryModel.fetchLibraryData()
                }
        }
    }
}

#Preview {
    LibraryNavigationStack()
}
