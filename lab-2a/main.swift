import Foundation

struct LedgerEntry {
    let title: String
    let category: String
    let amount: Double
    let isExpense: Bool
}

struct LearnerRecord {
    let studentName: String
    let score: Int
}

func computeAverage(of values: [Double]) -> Double? {
    guard !values.isEmpty else { return nil }
    let sum = values.reduce(0.0, +)
    return sum / Double(values.count)
}

func findHighestValue(in values: [Double]) -> Double? {
    guard var peak = values.first else { return nil }
    for number in values.dropFirst() {
        if number > peak {
            peak = number
        }
    }
    return peak
}

func isValidEmailFormat(_ candidate: String) -> Bool {
    let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
    let segments = trimmed.split(separator: "@", omittingEmptySubsequences: false)
    guard segments.count == 2, !segments[0].isEmpty else { return false }
    let domainPart = segments[1]
    guard let dotIndex = domainPart.lastIndex(of: "."),
          dotIndex != domainPart.startIndex,
          domainPart.index(after: dotIndex) != domainPart.endIndex else {
        return false
    }
    return true
}

func formatDisplayName(firstName: String, lastName: String) -> String {
    let cleanFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    let cleanLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    return "\(cleanFirst) \(cleanLast)".trimmingCharacters(in: .whitespaces)
}

func totalExpensesFunctional(from entries: [LedgerEntry]) -> Double {
    return entries
        .filter { $0.isExpense }
        .map { $0.amount }
        .reduce(0.0, +)
}

func totalExpensesImperative(from entries: [LedgerEntry]) -> Double {
    var runningTotal = 0.0
    for item in entries {
        if item.isExpense {
            runningTotal += item.amount
        }
    }
    return runningTotal
}

func rankLearners(_ learners: [LearnerRecord]) -> [LearnerRecord] {
    return learners.sorted { first, second in
        if first.score != second.score {
            return first.score > second.score
        }
        return first.studentName.localizedCaseInsensitiveCompare(second.studentName) == .orderedAscending
    }
}

func spendingByCategory(from entries: [LedgerEntry]) -> [String: Double] {
    return entries
        .filter { $0.isExpense }
        .reduce(into: [String: Double]()) { summary, entry in
            summary[entry.category, default: 0.0] += entry.amount
        }
}

let sampleScores = [72.5, 88.0, 94.5, 81.0]
print("Mean Score: \(computeAverage(of: sampleScores) ?? 0.0)")
print("Max Score: \(findHighestValue(in: sampleScores) ?? 0.0)")
print("Email Check (valid): \(isValidEmailFormat("love.pandey@example.com"))")
print("Email Check (invalid): \(isValidEmailFormat("invalid-email@"))")
print("Formatted Name: \(formatDisplayName(firstName: "  love ", lastName: " pandey "))")

let monthlyEntries = [
    LedgerEntry(title: "Stipend", category: "Income", amount: 25000.0, isExpense: false),
    LedgerEntry(title: "Groceries", category: "Food", amount: 1850.0, isExpense: true),
    LedgerEntry(title: "Metro Card", category: "Travel", amount: 600.0, isExpense: true),
    LedgerEntry(title: "Cafe Lunch", category: "Food", amount: 450.0, isExpense: true)
]

print("Total Expenses (HOF): \(totalExpensesFunctional(from: monthlyEntries))")
print("Total Expenses (Loop): \(totalExpensesImperative(from: monthlyEntries))")
print("Category Breakdown: \(spendingByCategory(from: monthlyEntries))")

let batchLearners = [
    LearnerRecord(studentName: "Rohan", score: 88),
    LearnerRecord(studentName: "Ananya", score: 95),
    LearnerRecord(studentName: "Dev", score: 88),
    LearnerRecord(studentName: "Kabir", score: 79)
]

for student in rankLearners(batchLearners) {
    print("\(student.studentName): \(student.score)")
}
