import Foundation

struct GradeRecord {
    let rollCode: String
    let learnerName: String
    let marks: [Double]
}

class CohortGradebook {
    private var records: [String: GradeRecord] = [:]

    func enroll(_ record: GradeRecord) {
        records[record.rollCode] = record
    }

    func averageMark(for rollCode: String) -> Double? {
        guard let student = records[rollCode], !student.marks.isEmpty else {
            return nil
        }
        let sum = student.marks.reduce(0.0, +)
        return sum / Double(student.marks.count)
    }

    func passingLearners(threshold: Double) -> [String] {
        return records.values
            .filter { ($0.marks.reduce(0.0, +) / Double(max($0.marks.count, 1))) >= threshold }
            .map { $0.learnerName }
            .sorted()
    }
}

struct Stack<Element> {
    private var items: [Element] = []

    var isEmpty: Bool {
        return items.isEmpty
    }

    mutating func push(_ value: Element) {
        items.append(value)
    }

    mutating func pop() -> Element? {
        return items.popLast()
    }

    func peek() -> Element? {
        return items.last
    }
}

class MentorProfile {
    let name: String
    var activeProject: CapstoneTeam?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("MentorProfile \(name) deallocated")
    }
}

class CapstoneTeam {
    let teamCode: String
    weak var mentor: MentorProfile?
    var onStatusUpdate: (() -> Void)?

    init(teamCode: String) {
        self.teamCode = teamCode
    }

    func bindCallback() {
        onStatusUpdate = { [weak self] in
            guard let self = self else { return }
            print("Status refreshed for team \(self.teamCode)")
        }
    }

    deinit {
        print("CapstoneTeam \(teamCode) deallocated")
    }
}

enum GradeEntryError: Error {
    case invalidStudentCode(String)
    case outOfBoundsScore(Double)
}

func submitExamScore(rollCode: String, score: Double) throws -> String {
    let trimmed = rollCode.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.hasPrefix("M1-"), trimmed.count == 6 else {
        throw GradeEntryError.invalidStudentCode(rollCode)
    }
    guard (0.0...100.0).contains(score) else {
        throw GradeEntryError.outOfBoundsScore(score)
    }
    return "Accepted score \(score) for \(trimmed)"
}

let gradebook = CohortGradebook()
gradebook.enroll(GradeRecord(rollCode: "M1-101", learnerName: "Love Pandey", marks: [88.0, 92.0, 90.0]))
gradebook.enroll(GradeRecord(rollCode: "M1-102", learnerName: "Rohan Verma", marks: [64.0, 70.0]))
gradebook.enroll(GradeRecord(rollCode: "M1-103", learnerName: "Ananya Nair", marks: []))

print("M1-101 Average: \(gradebook.averageMark(for: "M1-101") ?? 0.0)")
print("M1-103 Average (empty marks): \(gradebook.averageMark(for: "M1-103") ?? 0.0)")
print("M1-999 Average (missing key): \(gradebook.averageMark(for: "M1-999") ?? 0.0)")
print("Passing Learners: \(gradebook.passingLearners(threshold: 75.0))")

var scoreStack = Stack<Int>()
scoreStack.push(85)
scoreStack.push(94)
print("Int Stack Top: \(scoreStack.peek() ?? -1), Popped: \(scoreStack.pop() ?? -1)")

var topicStack = Stack<String>()
topicStack.push("Optionals")
topicStack.push("Generics")
print("String Stack Top: \(topicStack.peek() ?? "None"), Popped: \(topicStack.pop() ?? "None")")

var leadMentor: MentorProfile? = MentorProfile(name: "Dr. Sharma")
var projectTeam: CapstoneTeam? = CapstoneTeam(teamCode: "TEAM-07")
leadMentor?.activeProject = projectTeam
projectTeam?.mentor = leadMentor
projectTeam?.bindCallback()
projectTeam?.onStatusUpdate?()

leadMentor = nil
projectTeam = nil

let submissionInputs: [(String, Double)] = [
    ("M1-101", 91.5),
    ("101", 85.0),
    ("M1-102", 115.0)
]

for (code, value) in submissionInputs {
    do {
        let receipt = try submitExamScore(rollCode: code, score: value)
        print(receipt)
    } catch GradeEntryError.invalidStudentCode(let badCode) {
        print("Validation Error: '\(badCode)' must match format M1-XXX.")
    } catch GradeEntryError.outOfBoundsScore(let badScore) {
        print("Validation Error: \(badScore) is outside the valid 0–100 range.")
    } catch {
        print("Unexpected error: \(error)")
    }
}
