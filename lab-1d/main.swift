import Foundation

struct StudentProfile {
    let fullName: String
    let homeAddress: String?
    let contactNumber: String?
}

let examRegistry: [String: Double] = [
    "STU-204": 88.5,
    "STU-209": 74.0,
    "STU-215": 95.0
]

func findScore(byRollCode rollCode: String) -> Double? {
    return examRegistry[rollCode]
}

func displayScoreReport(rollCode: String) {
    if let score = findScore(byRollCode: rollCode) {
        print("Result for \(rollCode): \(score)%")
    } else {
        print("Record unavailable for roll code: \(rollCode)")
    }
}

func validateSearchInput(_ rawField: String?) {
    guard let cleanedQuery = rawField?.trimmingCharacters(in: .whitespacesAndNewlines),
          !cleanedQuery.isEmpty else {
        print("Empty search field ignored.")
        return
    }
    displayScoreReport(rollCode: cleanedQuery)
}

func computeAdjustedMarks(rollCode: String) -> Double {
    let baseMarks = findScore(byRollCode: rollCode) ?? 0.0
    return baseMarks
}

func showFormattedAddress(for student: StudentProfile?) {
    let formattedCity = student?.homeAddress?.capitalized ?? "Address not listed"
    print("Student: \(student?.fullName ?? "Unknown") | Address: \(formattedCity)")
}

validateSearchInput("   ")
validateSearchInput(nil)
validateSearchInput("STU-204")
validateSearchInput("STU-999")

let confirmedScore = computeAdjustedMarks(rollCode: "STU-215")
let fallbackScore = computeAdjustedMarks(rollCode: "STU-000")
print("Confirmed: \(confirmedScore), Fallback: \(fallbackScore)")

let learnerOne = StudentProfile(fullName: "Aarav Sharma", homeAddress: "sector 14, gurugram", contactNumber: nil)
let learnerTwo = StudentProfile(fullName: "Meera Nair", homeAddress: nil, contactNumber: "9123456780")

showFormattedAddress(for: learnerOne)
showFormattedAddress(for: learnerTwo)
