//
//  RowEventView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 08/11/2025.
//

import SwiftUI

struct RowEventView: View {
    let oneEvent: Event
    
    var body: some View {
        HStack(spacing: 12) {
            
            // The event poster is on the left
            posterThumbnail
            
            // Texts
            VStack(alignment: .leading, spacing: 4) {
                Text(oneEvent.Title)
                    .font(.headline)
                
                Text(oneEvent.Date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(oneEvent.Venue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var posterThumbnail: some View {
        if let poster = oneEvent.Poster,
           !poster.isEmpty,
           let url = URL(string: poster) {
            
            // Use poster image as a small square thumbnail
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    ProgressView()
                case .failure(_):
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                @unknown default:
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                }
            }
            .frame(width: 40, height: 40)
            .background(Color("CardColor"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .clipped()
            
        } else {
            // Original calendar icon
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .padding(6)
                .background(Color("PrimaryColor").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
