import SwiftUI

final class LifecycleLogger: ObservableObject {
    @Published private(set) var entries: [String] = []

    func record(_ event: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] \(event)"
        entries.append(line)
        print(line)
    }
}

@main
struct LifecycleDemoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var logger = LifecycleLogger()
    @AppStorage("savedDraftNote") private var persistedDraft: String = ""
    @State private var activeDraft: String = ""

    var body: some Scene {
        WindowGroup {
            PrimaryDashboardView(
                logger: logger,
                draftText: $activeDraft
            )
            .onAppear {
                activeDraft = persistedDraft
                logger.record("Root View: onAppear (Restored draft)")
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                activeDraft = persistedDraft
                logger.record("ScenePhase: \(oldPhase) -> active")
            case .inactive:
                logger.record("ScenePhase: \(oldPhase) -> inactive")
            case .background:
                persistedDraft = activeDraft
                logger.record("ScenePhase: \(oldPhase) -> background (Saved draft)")
            @unknown default:
                logger.record("ScenePhase: unknown state")
            }
        }
    }
}

struct PrimaryDashboardView: View {
    @ObservedObject var logger: LifecycleLogger
    @Binding var draftText: String
    @State private var appearanceCounter: Int = 0
    @State private var lastRefreshedAt: String = "Never"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Screen 1: Dashboard")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Appearances: \(appearanceCounter) | Last Refresh: \(lastRefreshedAt)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Type draft note (auto-saves on background)", text: $draftText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                NavigationLink("Open Detail Screen") {
                    SecondaryDetailView(logger: logger)
                }
                .buttonStyle(.borderedProminent)

                List(logger.entries.reversed(), id: \.self) { entry in
                    Text(entry)
                        .font(.system(.caption, design: .monospaced))
                }
            }
            .padding(.top, 12)
            .navigationTitle("Lifecycle Monitor")
            .onAppear {
                appearanceCounter += 1
                logger.record("Screen 1 (Dashboard): onAppear (#\(appearanceCounter))")
                performLightweightRefresh()
            }
            .onDisappear {
                logger.record("Screen 1 (Dashboard): onDisappear")
            }
        }
    }

    private func performLightweightRefresh() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        lastRefreshedAt = formatter.string(from: Date())
        logger.record("Screen 1: Lightweight timestamp refresh executed")
    }
}

struct SecondaryDetailView: View {
    @ObservedObject var logger: LifecycleLogger

    var body: some View {
        VStack(spacing: 18) {
            Text("Screen 2: Detail View")
                .font(.title2)
                .fontWeight(.bold)

            Text("Navigate back to observe Screen 2 onDisappear and Screen 1 onAppear firing again.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle("Detail")
        .onAppear {
            logger.record("Screen 2 (Detail): onAppear")
        }
        .onDisappear {
            logger.record("Screen 2 (Detail): onDisappear")
        }
    }
}
