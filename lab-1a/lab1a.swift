import Foundation

func determineGrade(scorePercentage: Double, eligibleToPass: Bool) -> String {
    if !eligibleToPass {
        return "F"
    }
    switch scorePercentage {
    case 90.0...100.0:
        return "O"
    case 80.0..<90.0:
        return "A+"
    case 70.0..<80.0:
        return "A"
    case 60.0..<70.0:
        return "B"
    case 40.0..<60.0:
        return "C"
    default:
        return "F"
    }
}

func runStudentReport(
    studentName: String,
    rollId: String,
    subjectScores: [Double],
    attendanceRate: Double,
    extraCredit: Double?,
    mentorNote: String?
) {
    let fullMarksPerPaper: Double = 100.0
    let minimumSubjectPass: Double = 40.0
    let requiredAttendance: Double = 75.0
    let paperCount = Double(subjectScores.count)

    print("==========================================")
    print("Candidate: \(studentName) | ID: \(rollId)")

    if subjectScores.count != 5 {
        print("Error: Five subject scores are mandatory.")
        return
    }

    for score in subjectScores {
        if score < 0.0 || score > fullMarksPerPaper {
            print("Error: Score \(score) is outside valid range (0-100).")
            return
        }
    }

    if attendanceRate < 0.0 || attendanceRate > 100.0 {
        print("Error: Attendance \(attendanceRate)% is outside valid range (0-100).")
        return
    }

    let appliedCredit = extraCredit ?? 0.0
    let displayNote = mentorNote ?? "None"

    var aggregateMarks: Double = 0.0
    var clearedAllPapers: Bool = true

    for score in subjectScores {
        aggregateMarks += score
        if score < minimumSubjectPass {
            clearedAllPapers = false
        }
    }

    let maximumAggregate = fullMarksPerPaper * paperCount
    aggregateMarks += appliedCredit
    if aggregateMarks > maximumAggregate {
        let overflow = aggregateMarks - maximumAggregate
        aggregateMarks -= overflow
    }

    var meanScore: Double = aggregateMarks / paperCount
    var overallPercentage: Double = (aggregateMarks / maximumAggregate) * 100.0
    let moduloRemainder = Int(aggregateMarks) % 5

    let attendanceQualified = attendanceRate >= requiredAttendance
    var finalPassStatus: Bool = clearedAllPapers && attendanceQualified
    let awardedGrade = determineGrade(scorePercentage: overallPercentage, eligibleToPass: finalPassStatus)
    let outcomeLabel = finalPassStatus ? "PASSED" : "FAILED"

    print("Scores: \(subjectScores)")
    print(String(format: "Aggregate: %.1f / %.0f | Mean: %.2f | Percentage: %.2f%%", aggregateMarks, maximumAggregate, meanScore, overallPercentage))
    print(String(format: "Attendance: %.1f%% | Bonus Applied: %.1f | Remainder: %d", attendanceRate, appliedCredit, moduloRemainder))
    print("Status: \(outcomeLabel) | Grade: \(awardedGrade) | Note: \(displayNote)")
}

runStudentReport(studentName: "Devansh Kulkarni", rollId: "WIP-201", subjectScores: [94, 91, 97, 93, 96], attendanceRate: 96.0, extraCredit: nil, mentorNote: nil)
runStudentReport(studentName: "Sneha Iyer", rollId: "WIP-202", subjectScores: [64, 71, 69, 73, 62], attendanceRate: 84.0, extraCredit: 4.0, mentorNote: "Steady progress")
runStudentReport(studentName: "Karan Malhotra", rollId: "WIP-203", subjectScores: [100, 100, 100, 100, 100], attendanceRate: 100.0, extraCredit: nil, mentorNote: "Top scorer")
runStudentReport(studentName: "Pooja Joshi", rollId: "WIP-204", subjectScores: [0, 0, 0, 0, 0], attendanceRate: 80.0, extraCredit: nil, mentorNote: nil)
runStudentReport(studentName: "Harshvardhan Rao", rollId: "WIP-205", subjectScores: [82, 79, 31, 76, 88], attendanceRate: 91.0, extraCredit: nil, mentorNote: "Retake required in Paper 3")
runStudentReport(studentName: "Nandini Menon", rollId: "WIP-206", subjectScores: [81, 86, 84, 79, 89], attendanceRate: 68.0, extraCredit: nil, mentorNote: "Low attendance")
runStudentReport(studentName: "Siddharth Bose", rollId: "WIP-207", subjectScores: [104, 80, -3, 72, 85], attendanceRate: 88.0, extraCredit: nil, mentorNote: nil)
runStudentReport(studentName: "Tanya Chawla", rollId: "WIP-208", subjectScores: [76, 81, 79, 83, 80], attendanceRate: 108.0, extraCredit: nil, mentorNote: nil)
