import Foundation

enum ValidationError: Error {
    case emptyName
    case invalidMark(entered: Double)
    case invalidID(entered: String)
}

enum NetworkFailure: Error {
    case timeout
    case unauthorized
    case badServerCode(Int)
}

struct RegisteredLearner {
    let rollCode: String
    let fullName: String
    let score: Double
}

func enrollLearner(rollCode: String, fullName: String, score: Double) throws -> RegisteredLearner {
    let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else {
        throw ValidationError.emptyName
    }

    let trimmedID = rollCode.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmedID.hasPrefix("W-"), trimmedID.count == 6 else {
        throw ValidationError.invalidID(entered: rollCode)
    }

    guard score >= 0.0 && score <= 100.0 else {
        throw ValidationError.invalidMark(entered: score)
    }

    return RegisteredLearner(rollCode: trimmedID, fullName: trimmedName, score: score)
}

func attemptEnrollment(rollCode: String, fullName: String, score: Double) {
    do {
        let learner = try enrollLearner(rollCode: rollCode, fullName: fullName, score: score)
        print("Enrolled: \(learner.fullName) [\(learner.rollCode)] - Score: \(learner.score)")
    } catch ValidationError.emptyName {
        print("Registration rejected: Student name cannot be blank.")
    } catch ValidationError.invalidID(let badID) {
        print("Registration rejected: '\(badID)' must follow format W-XXXX.")
    } catch ValidationError.invalidMark(let badScore) {
        print("Registration rejected: Score \(badScore) must be between 0 and 100.")
    } catch {
        print("Registration rejected due to an unexpected error: \(error)")
    }
}

func parseGradeOptional(_ text: String) -> Int? {
    guard let value = Int(text), (0...100).contains(value) else {
        return nil
    }
    return value
}

func parseGradeResult(_ text: String) -> Result<Int, ValidationError> {
    guard let value = Int(text), (0...100).contains(value) else {
        return .failure(.invalidMark(entered: Double(text) ?? -1))
    }
    return .success(value)
}

func fetchRemoteProfile(simulateFail: Bool) -> Result<String, NetworkFailure> {
    if simulateFail {
        return .failure(.badServerCode(503))
    }
    return .success("{\"status\":\"active\",\"batch\":\"iOS-2026\"}")
}

func friendlyMessage(for outcome: Result<String, NetworkFailure>) -> String {
    switch outcome {
    case .success(let payload):
        return "Loaded profile data: \(payload)"
    case .failure(.timeout):
        return "Connection timed out. Please check your internet and try again."
    case .failure(.unauthorized):
        return "Session expired. Please sign in again."
    case .failure(.badServerCode(let code)):
        return "Server is temporarily unavailable (Error \(code)). Try again shortly."
    }
}

attemptEnrollment(rollCode: "W-1042", fullName: "Love Pandey", score: 91.5)
attemptEnrollment(rollCode: "W-1043", fullName: "   ", score: 85.0)
attemptEnrollment(rollCode: "1044", fullName: "Riya Sen", score: 88.0)
attemptEnrollment(rollCode: "W-1045", fullName: "Kabir Das", score: 112.0)

let optionalOutcome = parseGradeOptional("105")
print("Optional Return Outcome: \(String(describing: optionalOutcome))")

let resultOutcome = parseGradeResult("105")
print("Result Outcome: \(resultOutcome)")

let serverResponse = fetchRemoteProfile(simulateFail: true)
print(friendlyMessage(for: serverResponse))
