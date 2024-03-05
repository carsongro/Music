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
    static let shared = LibraryModel()
    
    var playlists = MusicItemCollection<Playlist>()
    
    var searchText = ""
    
    private init() {
        fetchLibraryData()
    }
    
    func fetchLibraryData() {
        Task {
            do {
                let request = MusicLibraryRequest<Playlist>()
                let response = try await request.response()
                playlists = response.items
            } catch {
                print("Error fetching library playlists: \(error.localizedDescription)")
            }
        }
    }
}
