import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var stats = BananaStats.cached() ?? .empty
    @State private var loading = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row("🍌 Playing now", Fmt.num(stats.players))
                    row("Wishlists", Fmt.num(stats.wishlists))
                    row("Wishlists today", Fmt.signed(stats.wishlistsToday))
                    row("Updated", Fmt.time(stats.updatedAt))
                } footer: {
                    Text("Add the Banana Stats widget to your Home Screen. It refreshes about every 15 minutes.")
                }
                Section {
                    Link("Open banana-stats", destination: BananaStats.statsPage)
                }
            }
            .navigationTitle("Banana Stats")
            .toolbar {
                Button { Task { await refresh() } } label: {
                    if loading { ProgressView() } else { Image(systemName: "arrow.clockwise") }
                }
            }
            .refreshable { await refresh() }
            .task { await refresh() }
            // Coming back to the app is the user's "refresh the widget" gesture.
            .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await refresh() } } }
        }
    }
    private func row(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).monospacedDigit().foregroundStyle(.secondary) }
    }
    private func refresh() async {
        loading = true
        stats = await BananaStats.fetch()
        loading = false
        WidgetCenter.shared.reloadAllTimelines()
    }
}
