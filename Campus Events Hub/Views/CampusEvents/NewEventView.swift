//
//  NewEventView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 08/11/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage   // make sure FirebaseStorage is added so images could be stored

struct NewEventView: View {

    @State private var newEvent = Event(
        Title: "",
        Description: "",
        Date: Date(),
        City: "",
        Venue: "",
        Source: "Campus",
        Poster: nil,
        latitude: nil,
        longitude: nil
    )

    // text fields for user input
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    
    @State private var posterImage: UIImage? = nil
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var isSaving = false
    
    @Environment(\.dismiss) var dismiss
    
    // ------------ UI ------------
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                Form {
                    // --- MAIN EVENT DETAILS ---
                    Section(header: Text("Event Details")) {
                        TextField("Title", text: $newEvent.Title)
                        
                        DatePicker(
                            "Date & Time",
                            selection: $newEvent.Date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        TextField("City", text: $newEvent.City)
                        TextField("Venue", text: $newEvent.Venue)
                        
                        TextField("Description", text: $newEvent.Description, axis: .vertical)
                            .lineLimit(3...6)
                        
                        TextField("Source", text: $newEvent.Source)
                    }
                    .listRowBackground(Color("CardColor"))
                    
                    //---LOCATION (OPTIONAL)---//
                    Section(header: Text("Location (optional)")) {
                        TextField("Latitude", text: $latitudeText)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", text: $longitudeText)
                            .keyboardType(.decimalPad)
                        
                        Text("Add coordinates to show this event on the map.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color("CardColor"))
                    
                    //---POSTER (OPTIONAL)---//
                    Section(header: Text("Poster (optional)")) {
                        if let img = posterImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
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
                            addNewEvent()
                        } label: {
                            if isSaving {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            } else {
                                Text("Save Event")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isSaving || newEvent.Title
                            .trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.bordered)
                        .tint(Color("PrimaryColor"))
                    }
                    .listRowBackground(Color("CardColor"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add New Event")
            .navigationBarTitleDisplayMode(.inline)
        }
        // camera + gallery modals
        .sheet(isPresented: $showCamera) {
            CameraManager(selectedImage: $posterImage, sourceType: .camera)
        }
        .sheet(isPresented: $showGallery) {
            CameraManager(selectedImage: $posterImage, sourceType: .photoLibrary)
        }
    }
    
    // ----------FUNCTIONS----------//
    
    private func addNewEvent() {
        newEvent.Title = newEvent.Title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newEvent.Title.isEmpty else { return }
        
        // set the location from text (optional)
        if let lat = Double(latitudeText), let lon = Double(longitudeText) {
            newEvent.latitude = lat
            newEvent.longitude = lon
        } else {
            newEvent.latitude = nil
            newEvent.longitude = nil
        }
        
        isSaving = true
        
        // 1- if we have an image, upload first
        if let img = posterImage {
            uploadPoster(image: img) { urlString in
                newEvent.Poster = urlString
                saveEventDocument()
            }
        } else {
            // 2- no image -> just save the event
            saveEventDocument()
        }
    }
    
    private func saveEventDocument() {
        let eventsRef = Firestore.firestore().collection("Events")
        
        var data: [String: Any] = [
            "Title": newEvent.Title,
            "Description": newEvent.Description,
            "Date": Timestamp(date: newEvent.Date),
            "City": newEvent.City,
            "Venue": newEvent.Venue,
            "Source": newEvent.Source
        ]
        
        if let poster = newEvent.Poster, !poster.isEmpty {
            data["Poster"] = poster
        }
        
        // include location if available
        if let lat = newEvent.latitude, let lon = newEvent.longitude {
            data["latitude"] = lat
            data["longitude"] = lon
        }
        
        eventsRef.addDocument(data: data) { error in
            isSaving = false
            if let error = error {
                print("Error adding event: \(error.localizedDescription)")
            } else {
                print("Event added successfully")
                dismiss()
            }
        }
    }
    
    // upload to Firebase Storage
    private func uploadPoster(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
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
    NewEventView()
}
