//
//  Event.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 07/11/2025.
//


//-----Cumpus Events-----//
import SwiftUI
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var Title: String
    var Description: String
    var Date: Date
    var City: String
    var Venue: String
    var Source: String
    var Poster: String?
    var latitude: Double?
    var longitude: Double?
}
