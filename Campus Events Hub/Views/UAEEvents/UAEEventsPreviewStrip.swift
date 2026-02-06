//
//  AEEventsPreviewStrip.Swift
//  Campus Events Hub
//
//  Created by Amna Al Buraiki on 17/11/2025.
//
//

import SwiftUI

struct UAEEventsPreviewStrip: View {
    
    @State private var remoteEvents: [RemoteEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAll = false     // to open full list
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header: title + View all
            HStack {
                Text("UAE Events")
                    .font(.headline)
                
                Spacer()
                
                Button("View all") {
                    showAll = true
                }
                .font(.subheadline)
                .foregroundColor(Color("PrimaryColor"))
            }
            .padding(.horizontal, 16)
            
            // Content
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 12)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            } else {
                // Horizontal scroll, ONLY FIRST 3 EVENTS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(remoteEvents.prefix(3)) { event in
                            UAEEventCard(event: event)
                                .frame(width: 260)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color("CardColor").opacity(0.4))
        .cornerRadius(24)
        .padding(.horizontal)
        .sheet(isPresented: $showAll) {
            // full screen with all upcoming events
            NavigationStack {
                UAEEventsView()
            }
        }
        .onAppear {
            if remoteEvents.isEmpty {
                loadEvents()
            }
        }
    }
    
    // ----------FUNCTIONS----------//
    private func loadEvents() { // load the events from JSON
        guard let url = URL(string: "https://ed46cd907c564a10a26de530462262a3.api.mockbin.io/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([RemoteEvent].self, from: data)
                DispatchQueue.main.async {
                    self.remoteEvents = decoded
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decode error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
