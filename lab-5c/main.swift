import Foundation

struct ModuleMetadata: Sendable {
    let courseID: String
    let title: String
    let instructor: String
}

enum CatalogFetchError: Error, CustomStringConvertible {
    case unavailableCourse(String)

    var description: String {
        switch self {
        case .unavailableCourse(let id):
            return "Course \(id) could not be retrieved from server"
        }
    }
}

func fetchCourseDetail(for courseID: String, delayMilliseconds: UInt64 = 400, shouldFail: Bool = false) async throws -> ModuleMetadata {
    try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
    try Task.checkCancellation()

    if shouldFail {
        throw CatalogFetchError.unavailableCourse(courseID)
    }

    let directory: [String: (String, String)] = [
        "IOS-101": ("Swift Basics & Types", "Aarav Mehta"),
        "IOS-202": ("Protocols & Generics", "Priya Nair"),
        "IOS-303": ("UIKit vs SwiftUI", "Rohan Kapoor"),
        "IOS-404": ("MVVM Architecture", "Sneha Iyer"),
        "IOS-505": ("Structured Concurrency", "Vikram Rao")
    ]

    let info = directory[courseID] ?? ("General Elective", "Staff")
    return ModuleMetadata(courseID: courseID, title: info.0, instructor: info.1)
}

func fetchSequentially(courseIDs: [String]) async throws -> [ModuleMetadata] {
    var collected: [ModuleMetadata] = []
    for id in courseIDs {
        let item = try await fetchCourseDetail(for: id)
        collected.append(item)
    }
    return collected
}

func fetchConcurrentlyAllOrNothing(courseIDs: [String], failingID: String? = nil) async throws -> [ModuleMetadata] {
    return try await withThrowingTaskGroup(of: (Int, ModuleMetadata).self) { group in
        for (index, id) in courseIDs.enumerated() {
            group.addTask {
                let failThisChild = (id == failingID)
                let detail = try await fetchCourseDetail(for: id, shouldFail: failThisChild)
                return (index, detail)
            }
        }

        var ordered = Array<ModuleMetadata?>(repeating: nil, count: courseIDs.count)
        for try await (index, detail) in group {
            ordered[index] = detail
        }
        return ordered.compactMap { $0 }
    }
}

func fetchConcurrentlyPartialResults(courseIDs: [String], failingID: String? = nil) async -> (succeeded: [ModuleMetadata], failedIDs: [String]) {
    return await withTaskGroup(of: Result<ModuleMetadata, CatalogFetchError>.self) { group in
        for id in courseIDs {
            group.addTask {
                do {
                    let detail = try await fetchCourseDetail(for: id, shouldFail: id == failingID)
                    return .success(detail)
                } catch let error as CatalogFetchError {
                    return .failure(error)
                } catch {
                    return .failure(.unavailableCourse(id))
                }
            }
        }

        var loaded: [ModuleMetadata] = []
        var failed: [String] = []

        for await outcome in group {
            switch outcome {
            case .success(let metadata):
                loaded.append(metadata)
            case .failure(let error):
                failed.append(error.description)
            }
        }
        return (loaded, failed)
    }
}

func fetchWithConcurrencyLimit(courseIDs: [String], maxConcurrent: Int) async throws -> [ModuleMetadata] {
    return try await withThrowingTaskGroup(of: ModuleMetadata.self) { group in
        var iterator = courseIDs.makeIterator()
        var results: [ModuleMetadata] = []

        for _ in 0..<maxConcurrent {
            if let nextID = iterator.next() {
                group.addTask {
                    try await fetchCourseDetail(for: nextID)
                }
            }
        }

        while let completed = try await group.next() {
            results.append(completed)
            if let nextID = iterator.next() {
                group.addTask {
                    try await fetchCourseDetail(for: nextID)
                }
            }
        }
        return results
    }
}

let semaphore = DispatchSemaphore(value: 0)

Task {
    let targetIDs = ["IOS-101", "IOS-202", "IOS-303", "IOS-404"]
    let clock = ContinuousClock()

    let sequentialTime = try await clock.measure {
        let items = try await fetchSequentially(courseIDs: targetIDs)
        print("Sequential fetched \(items.count) courses.")
    }
    print("Sequential Elapsed Time: \(sequentialTime)")

    let concurrentTime = try await clock.measure {
        let items = try await fetchConcurrentlyAllOrNothing(courseIDs: targetIDs)
        print("Concurrent fetched \(items.count) courses in order: \(items.map { $0.courseID })")
    }
    print("Concurrent Elapsed Time: \(concurrentTime)")

    do {
        _ = try await fetchConcurrentlyAllOrNothing(courseIDs: targetIDs, failingID: "IOS-303")
    } catch {
        print("All-or-Nothing Strategy Aborted: \(error)")
    }

    let partialOutcome = await fetchConcurrentlyPartialResults(courseIDs: targetIDs, failingID: "IOS-303")
    print("Partial Strategy Succeeded (\(partialOutcome.succeeded.count)): \(partialOutcome.succeeded.map { $0.courseID })")
    print("Partial Strategy Failed (\(partialOutcome.failedIDs.count)): \(partialOutcome.failedIDs)")

    let boundedTime = try await clock.measure {
        let limitedItems = try await fetchWithConcurrencyLimit(courseIDs: ["IOS-101", "IOS-202", "IOS-303", "IOS-404", "IOS-505"], maxConcurrent: 2)
        print("Max-Concurrency (2) fetched \(limitedItems.count) courses.")
    }
    print("Bounded Concurrency (max 2) Elapsed Time: \(boundedTime)")

    semaphore.signal()
}

semaphore.wait()
