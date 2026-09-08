//
//  SongRow.swift
//  MusicPlayerApp
//
//  Created by charlie siagian on 08/09/26.
//

import SwiftUI

struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    let onPlay: () -> Void
    
    var body: some View {
        
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onPlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 32))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
