import SwiftUI

@main
struct Zadanie4App: App {
    // Data lives in memory only (allowed by the assignment).
    @StateObject private var store = PersonStore()

    var body: some Scene {
        WindowGroup {
            PersonListView()
                .environmentObject(store)
        }
    }
}
