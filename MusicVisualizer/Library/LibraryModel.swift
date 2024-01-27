//
//  LibraryModel.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/27/24.
//

import Foundation
import MusicKit

@Observable
final class LibraryModel {
    var playlists = MusicItemCollection<Playlist>()
    
    var searchText = ""
    
    init() {
        fetchLibraryData()
    }
    
    func fetchLibraryData() {
        let request = MusicLibraryRequest<Playlist>()
        Task {
            do {
                let response = try await request.response()
                playlists = response.items
            } catch {
                print("Error fetching library playlists: \(error.localizedDescription)")
            }
        }
    }
}
