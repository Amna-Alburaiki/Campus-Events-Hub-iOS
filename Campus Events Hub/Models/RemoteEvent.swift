//
//  RemoteEvent.swift
//  Campus Events Hub
//
//  Created by Amna Al Buraiki on 16/11/2025.
//

//----JSON - UAE Events----//
import Foundation

struct RemoteEvent: Identifiable, Decodable {
    // The local ID used only in the app not in JSON
    var id = UUID()

    let title: String
    let city: String
    let venue: String
    let dateISO: String
    let description: String
    let source: String
    let imageURL: String?
    let link: String?

    // This will tell the decoder to ignore `id`
    enum CodingKeys: String, CodingKey {
        case title, city, venue, dateISO, description, source, imageURL, link
    }

    var eventDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateISO) ?? Date()
    }
}

extension RemoteEvent {
    var venueLine: String {
        "\(venue), \(city)"
    }
}
