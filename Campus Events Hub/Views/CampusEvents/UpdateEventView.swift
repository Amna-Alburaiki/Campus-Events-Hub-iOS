//
//  UpdateEventView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 08/11/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct UpdateEventView: View {
    
    // event passed from ContentView sheet
    let myEvent: Event
    
    // local editable copy
    @State private var editableEvent: Event
    
    // text fields for Location
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    
    // poster image
    @State private var posterImage: UIImage? = nil
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var isSaving = false
    
    @Environment(\.dismiss) var dismiss
    
    // Firestore reference
    let eventsRef = Firestore.firestore().collection("Events")
    
    // custom init to fill editableEvent
    init(myEvent: Event) {
        self.myEvent = myEvent
        _editableEvent = State(initialValue: myEvent)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                Form {
                    //----EVENT DETAILS----//
                    Section(header: Text("Event Details")) {
                        TextField("Title", text: $editableEvent.Title)
                        
                        DatePicker(
                            "Date & Time",
                            selection: $editableEvent.Date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        TextField("City", text: $editableEvent.City)
                        TextField("Venue", text: $editableEvent.Venue)
                        
                        TextField("Description", text: $editableEvent.Description, axis: .vertical)
                            .lineLimit(3...6)
                        
                        TextField("Source", text: $editableEvent.Source)
                    }
                    .listRowBackground(Color("CardColor"))
                    
                    //----LOCATION (OPTIONAL)----//
                    Section(header: Text("Location (optional)")) {
                        TextField("Latitude", text: $latitudeText)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", text: $longitudeText)
                            .keyboardType(.decimalPad)
                        
                        Text("Update coordinates to show this event on the map.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color("CardColor"))
                    
                    //----POSTER (OPTIONAL)----//
                    Section(header: Text("Poster (optional)")) {
                        if let img = posterImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .cornerRadius(16)
                                .shadow(radius: 3)
                        } else if let urlString = editableEvent.Poster,
                                  let url = URL(string: urlString) {
                            // show existing poster from URL
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 180)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("BackgroundColor"))
                                .frame(height: 120)
                                .overlay(
                                    Text("No poster selected")
                                        .foregroundColor(Color("TextLight"))
                                )
                        }
                        
                        HStack(spacing: 16) {
                            Button {
                                showCamera = true
                            } label: {
                                Label("Camera", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button {
                                showGallery = true
                            } label: {
                                Label("Gallery", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("PrimaryColor"))
                    }
                    .listRowBackground(Color("CardColor"))
                    
                    //----SAVE BUTTON----//
                    Section {
                        Button {
                            updateEvent()
                        } label: {
                            if isSaving {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            } else {
                                Text("Save Changes")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isSaving || editableEvent.Title
                            .trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.bordered)
                        .tint(Color("PrimaryColor"))
                    }
                    .listRowBackground(Color("CardColor"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Update Event")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCamera) {
            CameraManager(selectedImage: $posterImage, sourceType: .camera)
        }
        .sheet(isPresented: $showGallery) {
            CameraManager(selectedImage: $posterImage, sourceType: .photoLibrary)
        }
        .onAppear {
            // fill latitude/longitude text from existing event
            if let lat = editableEvent.latitude {
                latitudeText = String(lat)
            }
            if let lon = editableEvent.longitude {
                longitudeText = String(lon)
            }
        }
    }
    
    // ----------FUNCTIONS----------//
    
    private func updateEvent() {
        editableEvent.Title = editableEvent.Title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !editableEvent.Title.isEmpty else { return }
        guard let id = editableEvent.id else {
            print("No ID → cannot update")
            return
        }
        
        // update coordinates from text
        if let lat = Double(latitudeText), let lon = Double(longitudeText) {
            editableEvent.latitude = lat
            editableEvent.longitude = lon
        } else {
            editableEvent.latitude = nil
            editableEvent.longitude = nil
        }
        
        isSaving = true
        
        // Only replace Poster when we actually get a new URL
        if let img = posterImage {
            uploadPoster(image: img) { urlString in
                if let urlString = urlString {
                    self.editableEvent.Poster = urlString
                }
                self.saveUpdatedDocument(id: id)
            }
        } else {
            // no new image → keep existing Poster value
            saveUpdatedDocument(id: id)
        }
    }
    
    private func saveUpdatedDocument(id: String) {
        var data: [String: Any] = [
            "Title": editableEvent.Title,
            "Description": editableEvent.Description,
            "Date": Timestamp(date: editableEvent.Date),
            "City": editableEvent.City,
            "Venue": editableEvent.Venue,
            "Source": editableEvent.Source
        ]
        
        if let poster = editableEvent.Poster, !poster.isEmpty {
            data["Poster"] = poster
        }
        if let lat = editableEvent.latitude, let lon = editableEvent.longitude {
            data["latitude"] = lat
            data["longitude"] = lon
        }
        
        eventsRef.document(id).setData(data, merge: true) { error in
            isSaving = false
            if let error = error {
                print("Error updating event: \(error.localizedDescription)")
            } else {
                print("✅ Event updated successfully")
                dismiss()
            }
        }
    }
    
    // same upload helper as NewEventView
    private func uploadPoster(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil); return
        }
        
        let fileName = "poster-\(UUID().uuidString).jpg"
        let storageRef = Storage.storage()
            .reference()
            .child("eventPosters")
            .child(fileName)
        
        storageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Storage upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
}

#Preview {
    // sample preview event
    let sample = Event(
        id: "123",
        Title: "Sample Event",
        Description: "Desc",
        Date: Date(),
        City: "Abu Dhabi",
        Venue: "HCT",
        Source: "Campus",
        Poster: nil,
        latitude: 24.4539,
        longitude: 54.3773
    )
    return UpdateEventView(myEvent: sample)
}
