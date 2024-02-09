//
//  SearchNavigaitonStack.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/24/24.
//

import SwiftUI
import MusicKit

struct SearchNavigaitonStack: View {
    @State private var searchTerm = ""
    @State private var recentAlbumsStorage = RecentAlbumsStorage.shared
    
    /// The albums the app loads using MusicKit that match the current search term.
    @State private var albums: MusicItemCollection<Album> = []
    @State private var songs: MusicItemCollection<Song> = []
    @State private var artists: MusicItemCollection<Artist> = []
    @State private var topResults: MusicItemCollection<MusicCatalogSearchResponse.TopResult> = []
    
    var body: some View {
        NavigationStack {
            VStack {
                searchResultsList
                    .animation(.default, value: albums)
                
                Spacer()
            }
            .onAppear(perform: recentAlbumsStorage.loadRecentlyViewedAlbums)
            .onChange(of: WelcomeView.PresentationCoordinator.shared.musicAuthorizationStatus) { _, _ in
                recentAlbumsStorage.loadRecentlyViewedAlbums()
            }
            .onChange(of: searchTerm) { _, _ in
                requestUpdatedSearchResults(for: searchTerm)
            }
            .welcomeSheet()
            .navigationTitle("Search")
            .searchable(text: $searchTerm, prompt: "Albums, Songs, and Artists")
            .musicNavigationDestinations()
        }
    }
    
    @State private var showingClearRecentConfirmation = false
    
    private var searchResultsList: some View {
        List {
            Section {
                clearRecent
            }
            .listRowSeparator(.hidden, edges: .top)
            
            Section {
                if topResults.isEmpty {
                    ForEach(recentAlbumsStorage.recentlyViewedAlbums) { album in
                        AlbumCell(album)
                    }
                } else {
                    ForEach(topResults) { result in
                        switch result {
                        case .album(let album):
                            AlbumCell(album)
                        case .artist(let artist):
                            ArtistCell(artist: artist)
                        case .song(let song):
                            SongCell(song) {
                                MusicPlayerManager.shared.handleSongSelected(song)
                            }
                        default:
                            Color.clear
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .contentMargins(.bottom, 65, for: .scrollContent)
    }
    
    @ViewBuilder
    private var clearRecent: some View {
        if albums.isEmpty && !recentAlbumsStorage.recentlyViewedAlbums.isEmpty {
            HStack {
                Text("Recently Searched")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Clear") {
                    showingClearRecentConfirmation = true
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
            }
            .font(.callout)
            .confirmationDialog(
                "Are you sure you want to clear your recent searches?",
                isPresented: $showingClearRecentConfirmation
            ) {
                Button("Clear", role: .destructive) {
                    withAnimation {
                        showingClearRecentConfirmation = false
                        recentAlbumsStorage.reset()
                        albums = []
                        searchTerm = ""
                    }
                }
            }
        }
    }
    
    /// Safely resets the `albums` property on the main thread.
    @MainActor
    private func reset() {
        self.topResults = []
    }
    
    /// Safely updates the `albums` property on the main thread.
    @MainActor
    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            self.topResults = searchResponse.topResults
        }
    }
    
    /// Makes a new search request to MusicKit when the current search term changes.
    private func requestUpdatedSearchResults(for searchTerm: String) {
        Task {
            if searchTerm.isEmpty {
                await reset()
            } else {
                do {
                    // Issue a catalog search request for albums matching the search term.
                    var searchRequest = MusicCatalogSearchRequest(
                        term: searchTerm,
                        types: [
                            Album.self,
                            Song.self,
                            Artist.self
                        ]
                    )
                    searchRequest.includeTopResults = true
                    searchRequest.limit = 10
                    let searchResponse = try await searchRequest.response()
                    
                    // Update the user interface with the search response.
                    await apply(searchResponse, for: searchTerm)
                } catch {
                    print("Search request failed with error: \(error).")
                    await reset()
                }
            }
        }
    }
}

#Preview {
    SearchNavigaitonStack()
}
