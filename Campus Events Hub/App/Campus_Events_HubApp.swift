//
//  Campus_Events_HubApp.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 07/11/2025.
//

import SwiftUI
import FirebaseCore

@main
struct Campus_Events_HubApp: App {
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
   init() {
       FirebaseApp.configure()
   }
    
}
