//
//  RecentAlbumsStorage.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import Foundation
import MusicKit

/// `RecentAlbumsStorage` allows storing persistent information about recently viewed albums.
/// It also offers a convenient way to observe those recently viewed albums.
@Observable class RecentAlbumsStorage {
    static let shared = RecentAlbumsStorage()
    
    var recentlyViewedAlbums: MusicItemCollection<Album> = []
    
    private let recentlyViewedAlbumIdentifiersKey = "recently-viewed-albums-identifiers"
    
    private let maximumNumberOfRecentlyViewedAlbums = 10
    
    /// Retrieves recently viewed album identifiers from `UserDefaults`.
    private var recentlyViewedAlbumIDs: [MusicItemID] {
        get {
            let rawRecentlyViewedAlbumIdentifiers = UserDefaults.standard.array(forKey: recentlyViewedAlbumIdentifiersKey) ?? []
            let recentlyViewedAlbumIDs = rawRecentlyViewedAlbumIdentifiers.compactMap { identifier -> MusicItemID? in
                var itemID: MusicItemID?
                if let stringIdentifier = identifier as? String {
                    itemID = MusicItemID(stringIdentifier)
                }
                return itemID
            }
            return recentlyViewedAlbumIDs
        }
        set {
            UserDefaults.standard.set(newValue.map(\.rawValue), forKey: recentlyViewedAlbumIdentifiersKey)
            loadRecentlyViewedAlbums()
        }
    }

    // TODO: MAKE THIS WORK
    /// Begins observing MusicKit authorization status.
    func beginObservingMusicAuthorizationStatus() {
        _ = withObservationTracking {
            WelcomeView.PresentationCoordinator.shared.musicAuthorizationStatus
        } onChange: {
            Task { @MainActor [weak self] in
                self?.loadRecentlyViewedAlbums()
                self?.beginObservingMusicAuthorizationStatus()
            }
        }
    }
    
    /// Clears recently viewed album identifiers from `UserDefaults`.
    func reset() {
        self.recentlyViewedAlbumIDs = []
    }
    
    /// Adds an album to the viewed album identifiers in `UserDefaults`.
    func update(with recentlyViewedAlbum: Album) {
        var recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
        if let index = recentlyViewedAlbumIDs.firstIndex(of: recentlyViewedAlbum.id) {
            recentlyViewedAlbumIDs.remove(at: index)
        }
        recentlyViewedAlbumIDs.insert(recentlyViewedAlbum.id, at: 0)
        while recentlyViewedAlbumIDs.count > maximumNumberOfRecentlyViewedAlbums {
            recentlyViewedAlbumIDs.removeLast()
        }
        self.recentlyViewedAlbumIDs = recentlyViewedAlbumIDs
    }
    
    /// Updates the recently viewed albums when MusicKit authorization status changes.
    func loadRecentlyViewedAlbums() {
        let recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
        if recentlyViewedAlbumIDs.isEmpty {
            self.recentlyViewedAlbums = []
        } else {
            Task {
                do {
                    let albumsRequest = MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: recentlyViewedAlbumIDs)
                    let albumsResponse = try await albumsRequest.response()
                    await self.updateRecentlyViewedAlbums(albumsResponse.items)
                } catch {
                    print("Failed to load albums for recently viewed album IDs: \(recentlyViewedAlbumIDs)")
                }
            }
        }
        
    }
    
    /// Safely changes `recentlyViewedAlbums` on the main thread.
    @MainActor
    private func updateRecentlyViewedAlbums(_ recentlyViewedAlbums: MusicItemCollection<Album>) {
        self.recentlyViewedAlbums = recentlyViewedAlbums
    }
}
