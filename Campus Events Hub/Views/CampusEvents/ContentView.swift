//
//  ContentView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 07/11/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    
    @State var isAdmin = false // new user by defualt not admin
    @State private var isLoggedIn = false
    
    // ----- Firebase + Data ------//
    @State private var listEvents: [Event] = []
    @State private var myListener: ListenerRegistration?
    let db = Firestore.firestore().collection("Events")
    
    // ----- UI State ------//
    @State private var showNewEvent = false
    @State private var selectedEventForUpdate: Event?
    
    //---delete confirmation---//
    @State private var showDeleteAlert = false
    @State private var eventToDelete: Event?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --------This is the main area either login or events--------//
            if isLoggedIn {
                NavigationView {
                    ZStack {
                        Color("BackgroundColor").ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            
                            //----Campus events list----//
                            List {
                                ForEach(listEvents) { oneEvent in
                                    NavigationLink(
                                        destination: EventDetailView(oneEvent: oneEvent)
                                    ) {
                                        RowEventView(oneEvent: oneEvent)
                                    }
                                    .swipeActions {
                                        if isAdmin { // Only admins can update/delete
                                            Button {
                                                selectedEventForUpdate = oneEvent
                                            } label: {
                                                Label("Update", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                eventToDelete = oneEvent
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                            
                            //---UAE events preview cards + View all---//
                            UAEEventsPreviewStrip()
                            
                            //----Sign out button----//
                            Button("Sign Out") {
                                signOut()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color("PrimaryColor"))
                            .padding(.bottom, 8)
                        }
                    }
                    .navigationTitle("Campus Events")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // Only admins get the + button
                        if isAdmin {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showNewEvent = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .padding(10)
                                        .background(Color("CardColor"))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .onAppear {
                        startListening()
                        loadUserRole()   // decide admin/normal for current user
                    }
                    .onDisappear {
                        stopListening()
                    }
                    // New event sheet
                    .sheet(isPresented: $showNewEvent) {
                        NewEventView()
                    }
                    // Update event sheet
                    .sheet(item: $selectedEventForUpdate) { event in
                        UpdateEventView(myEvent: event)
                    }
                    // Delete confirmation alert
                    .alert("Delete Event",
                           isPresented: $showDeleteAlert,
                           presenting: eventToDelete) { event in
                        Button("Delete", role: .destructive) {
                            deleteEvent(event)
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: { event in
                        Text("Are you sure you want to delete \"\(event.Title)\"?")
                    }
                }
                .navigationViewStyle(.stack)
            } else {
                // if new user (not logged in)
                SignUpView(isLoggedIn: $isLoggedIn)
            }
            
            //--------Footer is always visible--------//
            Text("Created by: Al Anood Khalifa & Amna Alburaiki")
                .foregroundStyle(.gray.opacity(0.5))
                .font(.system(size: 15))
                .padding(.bottom, 4)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .preferredColorScheme(.light) // ALWAYS LIGHT MODE on all devices
    }
    
    // ----------FUNCTIONS----------//
    
    func startListening() {
        myListener = db.addSnapshotListener { snap, error in
            if let error = error {
                print("Error reading Events: \(error.localizedDescription)")
                return
            }
            if let snap = snap {
                listEvents = snap.documents.compactMap { doc in
                    try? doc.data(as: Event.self)
                }
            }
        }
    }
    
    func stopListening() {
        myListener?.remove()
        myListener = nil
    }
    
    func deleteEvent(_ event: Event) {
        guard let id = event.id else {
            print("Unable to delete event: no id")
            return
        }
        
        db.document(id).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                print("Event deleted successfully")
            }
        }
    }
    
    func signOut() {
        guard isLoggedIn else { return }
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            isAdmin = false
            print("Sign Out successful")
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func loadUserRole() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("Users").document(uid).getDocument { doc, error in
            if let error = error {
                print("Error loading user role: \(error.localizedDescription)")
                self.isAdmin = false
                return
            }
            guard let doc = doc, doc.exists, let data = doc.data() else {
                print("No user document for uid \(uid)")
                self.isAdmin = false
                return
            }
            self.isAdmin = data["isAdmin"] as? Bool ?? false
            print("isAdmin = \(self.isAdmin)")
        }
    }
}

#Preview {
    ContentView()
}
