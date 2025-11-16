//
//  MoodlyApp.swift
//  Moodly
//
//  Created by Reed Rawlings on 11/15/25.
//

import SwiftUI
import SwiftData

@main
struct MoodlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MoodEntry.self,
            UserProfile.self,
            ActivityCorrelation.self,
            Trigger.self
        ])
    }
}
