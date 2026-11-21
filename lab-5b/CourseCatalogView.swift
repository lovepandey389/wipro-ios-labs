import SwiftUI

struct TrainingCourse: Identifiable, Equatable {
    let id: String
    let title: String
    let durationHours: Int
}

enum FetchScenario: String, CaseIterable, Identifiable {
    case populated = "Loaded"
    case empty = "Empty"
    case failure = "Failure"

    var id: String { rawValue }
}

enum CatalogLoadState: Equatable {
    case idle
    case loading
    case success([TrainingCourse])
    case empty
    case failure(String)
}

enum CatalogServiceError: LocalizedError {
    case networkUnreachable

    var errorDescription: String? {
        switch self {
        case .networkUnreachable:
            return "Unable to reach the course server. Please try again."
        }
    }
}

struct MockCourseRepository {
    func fetchCourses(scenario: FetchScenario) async throws -> [TrainingCourse] {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        try Task.checkCancellation()

        switch scenario {
        case .populated:
            return [
                TrainingCourse(id: "IOS-501", title: "Modern Swift Concurrency", durationHours: 6),
                TrainingCourse(id: "IOS-502", title: "Structured Task Groups", durationHours: 4),
                TrainingCourse(id: "IOS-503", title: "Actors & Data Isolation", durationHours: 5)
            ]
        case .empty:
            return []
        case .failure:
            throw CatalogServiceError.networkUnreachable
        }
    }
}

@MainActor
final class CourseCatalogViewModel: ObservableObject {
    @Published private(set) var state: CatalogLoadState = .idle
    @Published var selectedScenario: FetchScenario = .populated

    private let repository = MockCourseRepository()
    private var activeTask: Task<Void, Never>?

    func startFetch() {
        activeTask?.cancel()
        state = .loading

        let chosenScenario = selectedScenario
        activeTask = Task {
            do {
                let courses = try await repository.fetchCourses(scenario: chosenScenario)
                guard !Task.isCancelled else { return }
                state = courses.isEmpty ? .empty : .success(courses)
            } catch is CancellationError {
                state = .idle
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(error.localizedDescription)
            }
        }
    }

    func cancelFetch() {
        activeTask?.cancel()
        activeTask = nil
        state = .idle
    }
}

struct CourseCatalogView: View {
    @StateObject private var viewModel = CourseCatalogViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Response Mode", selection: $viewModel.selectedScenario) {
                    ForEach(FetchScenario.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("Load Courses") {
                        viewModel.startFetch()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.state == .loading)

                    if viewModel.state == .loading {
                        Button("Cancel", role: .destructive) {
                            viewModel.cancelFetch()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Spacer()

                switch viewModel.state {
                case .idle:
                    Text("Select a scenario and tap Load Courses.")
                        .foregroundStyle(.secondary)

                case .loading:
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Fetching courses...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                case .success(let courses):
                    List(courses) { course in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.title)
                                .font(.headline)
                            Text("\(course.id) • \(course.durationHours) hrs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                case .empty:
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No courses available right now.")
                            .foregroundStyle(.secondary)
                    }

                case .failure(let message):
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            viewModel.startFetch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                Spacer()
            }
            .padding(.top, 12)
            .navigationTitle("Course Catalog")
        }
    }
}
