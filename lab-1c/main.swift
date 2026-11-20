import Foundation

print("=== R1: Course Catalog (Array) ===")
var courseList = ["iOS Architecture", "Swift Syntax", "Core Animation", "SwiftUI Essentials", "URLSession Networking"]
print("Initial Courses: \(courseList)")

courseList.append("Combine Reactive")
if let indexToRemove = courseList.firstIndex(of: "Core Animation") {
    courseList.remove(at: indexToRemove)
}
print("Updated Courses: \(courseList)")

let sortedCourses = courseList.sorted()
print("Sorted Courses: \(sortedCourses)")

let swiftCourses = courseList.filter { $0.hasPrefix("Swift") }
print("Filtered ('Swift' prefix): \(swiftCourses)")

let targetCourse = "URLSession Networking"
let foundCourse = courseList.contains(targetCourse)
print("Search '\(targetCourse)': \(foundCourse ? "Found" : "Not Found")")

print("\n=== R2: Unique Student IDs (Set) ===")
let registeredIDs = [501, 504, 502, 501, 509, 504, 512, 502]
let uniqueIDs = Set(registeredIDs)
print("Total Submissions: \(registeredIDs.count)")
print("Unique IDs: \(uniqueIDs.sorted())")
print("Unique Student Count: \(uniqueIDs.count)")

print("\n=== R3: Student Marks & Topper (Dictionary) ===")
let studentMarks: [Int: Int] = [
    501: 82,
    502: 64,
    504: 95,
    509: 89,
    512: 58
]

if let topper = studentMarks.max(by: { $0.value < $1.value }) {
    print("Topper -> Student ID \(topper.key) scored \(topper.value)")
}

let minimumPass = 70
let lowScorers = studentMarks.filter { $0.value < minimumPass }
print("Students scoring below \(minimumPass):")
for (id, mark) in lowScorers.sorted(by: { $0.key < $1.key }) {
    print("- ID \(id): \(mark)")
}

print("\n=== R4: Task Priority (Enum & Switch) ===")
enum TaskUrgency {
    case low
    case medium
    case high
    case critical
}

func labelFor(_ urgency: TaskUrgency) -> String {
    switch urgency {
    case .low:
        return "Low Priority - Schedule when free"
    case .medium:
        return "Medium Priority - Complete this week"
    case .high:
        return "High Priority - Complete today"
    case .critical:
        return "Critical - Immediate action required"
    }
}

let queue: [TaskUrgency] = [.low, .high, .critical]
for item in queue {
    print(labelFor(item))
}

print("\n=== Extension: Enum with Associated Values ===")
enum NetworkOutcome {
    case success(itemCount: Int, endpoint: String)
    case failure(statusCode: Int, message: String)
}

func processOutcome(_ outcome: NetworkOutcome) {
    switch outcome {
    case .success(let count, let endpoint):
        print("Success: Retrieved \(count) records from \(endpoint)")
    case .failure(let code, let message):
        print("Error \(code): \(message)")
    }
}

processOutcome(.success(itemCount: uniqueIDs.count, endpoint: "/students"))
processOutcome(.failure(statusCode: 503, message: "Server temporarily unavailable"))
