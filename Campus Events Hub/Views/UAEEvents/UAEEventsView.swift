//
//  Untitled.swift
//  Campus Events Hub
//
//  Created by Amna Al Buraiki on 16/11/2025.
//
import SwiftUI

struct UAEEventsView: View {

    @State private var remoteEvents: [RemoteEvent] = []
    @State private var isLoading = false
    @State private var remoteError: String?
    @State private var selectedRange: RangeFilter = .week
    @State private var searchText: String = ""

    enum RangeFilter: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                
                rangeSelector // Filter events by time range (week/month/year). It updates the list so only events happening within the selected time
                searchBar // Search events by title or description

                if isLoading {
                    Spacer()
                    ProgressView("Loading events…")
                        .tint(Color("PrimaryColor"))
                    Spacer()
                } else if let remoteError {
                    Spacer()
                    Text(remoteError)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(filteredEvents) { event in
                                UAEEventCard(event: event)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .navigationTitle("UAE Events")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if remoteEvents.isEmpty {
                loadEvents()
            }
        }
    }


    private var rangeSelector: some View {
        HStack(spacing: 4) {
            ForEach(RangeFilter.allCases, id: \.self) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedRange == range
                                      ? Color("PrimaryColor")
                                      : Color.clear)
                        )
                        .foregroundColor(selectedRange == range
                                         ? Color("CardColor")
                                         : Color("TextDark"))
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color("CardColor").opacity(0.8))
        )
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("TextLight"))
            TextField("Search events", text: $searchText)
                .foregroundColor(Color("TextDark"))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardColor"))
        )
        .padding(.horizontal)
    }
    

    
    private var filteredEvents: [RemoteEvent] {
        let now = Date()
        let calendar = Calendar.current
        
        // Filter by time range
        let byRange = remoteEvents.filter { event in
            let date = event.eventDate
            switch selectedRange {
            case .week:
                if let weekAhead = calendar.date(byAdding: .day, value: 7, to: now) {
                    return date >= now && date <= weekAhead
                }
                return true
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }
        
        // Filter by search text
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return byRange
        } else {
            let lower = searchText.lowercased()
            return byRange.filter { event in
                event.title.lowercased().contains(lower) ||
                event.description.lowercased().contains(lower)
            }
        }
    }
    
    // ----------FUNCTIONS----------//
    
    private func loadEvents() {
        guard let url = URL(string: "https://ed46cd907c564a10a26de530462262a3.api.mockbin.io/") else {
            remoteError = "Invalid URL"
            return
        }
        
        isLoading = true
        remoteError = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.remoteError = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.remoteError = "No data received from web service"
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
                    self.remoteError = "Decode error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
