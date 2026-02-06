//
//  EventDetailView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 07/11/2025.
//

import SwiftUI
import MapKit
import FirebaseStorage

struct EventDetailView: View {
    let oneEvent: Event
    
    @State private var region: MKCoordinateRegion
    
    // Custom init
    init(oneEvent: Event) {
        self.oneEvent = oneEvent
        
        if let lat = oneEvent.latitude, let lon = oneEvent.longitude {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 24.4539, longitude: 54.3773),
                span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            ))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // -------- Poster --------//
                if let poster = oneEvent.Poster,
                   !poster.isEmpty,
                   let url = URL(string: poster) {
                    
                    AsyncImage(url: url) { img in
                        img.resizable()
                            .scaledToFit()
                            .frame(maxWidth: 260)
                            .cornerRadius(20)
                            .shadow(radius: 6)
                    } placeholder: {
                        ProgressView()
                    }
                    
                } else {
                    Image(systemName: "calendar.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color("PrimaryColor"))
                        .opacity(0.7)
                }
                
                
                // -------- Info Card --------//
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text(oneEvent.Title)
                        .font(.title2)
                        .bold()
                    
                    Text(oneEvent.Date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(Color("TextLight"))
                    
                    Divider()
                    
                    Text("City: \(oneEvent.City)")
                    Text("Venue: \(oneEvent.Venue)")
                    Text("Source: \(oneEvent.Source)")
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Divider()
                    
                    Text(oneEvent.Description)
                        .font(.body)
                        .foregroundColor(Color("TextDark"))
                }
                .padding()
                .background(Color("CardColor"))
                .cornerRadius(20)
                .shadow(radius: 4)
                .padding(.horizontal)
                
                
                // -------- Map Section --------//
                if let lat = oneEvent.latitude,
                   let lon = oneEvent.longitude {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Location")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Map(
                            coordinateRegion: $region,
                            annotationItems: [LocationPin(latitude: lat, longitude: lon)]
                        ) { pin in
                            MapMarker(coordinate: pin.coordinate, tint: .brown)
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
                
            }
            .padding(.top)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationPin: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
