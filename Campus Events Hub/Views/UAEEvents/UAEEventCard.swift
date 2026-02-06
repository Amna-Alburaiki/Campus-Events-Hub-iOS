//
//  UAEEventCard.swift
//  Campus Events Hub
//
//  Created by Amna Al Buraiki on 16/11/2025.
//

import SwiftUI

struct UAEEventCard: View {
    let event: RemoteEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Poster
            ZStack(alignment: .topLeading) {
                if let urlString = event.imageURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color("BackgroundColor")
                    }
                } else {
                    Color("BackgroundColor")
                }
            }
            .frame(height: 180)
            .clipped()

            // Text area
            VStack(alignment: .leading, spacing: 6) {
                Text(event.eventDate, style: .date)
                    .font(.caption)
                    .foregroundColor(Color("TextLight"))

                Text(event.title)
                    .font(.headline)
                    .foregroundColor(Color("TextDark"))

                Text(event.description)
                    .font(.caption)
                    .foregroundColor(Color("TextLight"))
                    .lineLimit(2)

                Text(event.venueLine)
                    .font(.caption2)
                    .foregroundColor(Color("TextLight"))

                if let link = event.link,
                   let url = URL(string: link) {
                    Button("Open Event Page") {
                        UIApplication.shared.open(url)
                    }
                    .font(.caption)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color("CardColor"))
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("CardColor"))
        )
        .cornerRadius(18)
        .shadow(radius: 3, y: 2)
    }
}

#Preview {
    let sample = RemoteEvent(
        title: "Sample Event",
        city: "Abu Dhabi",
        venue: "Jubail Island",
        dateISO: "2025-11-16T20:00:00Z",
        description: "Sample description for preview.",
        source: "Sample Source",
        imageURL: nil,
        link: nil
    )
    return UAEEventCard(event: sample)
}
