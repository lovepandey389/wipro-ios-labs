import Foundation

struct Trainee {
    let name: String
    let grade: Int
}

func runSimulatedSync(taskName: String, onComplete: (Bool, String) -> Void) {
    let payload = "Synced \(taskName) successfully"
    onComplete(true, payload)
}

func buildStepCounter(startingAt initial: Int = 0, stepBy increment: Int = 1) -> () -> Int {
    var runningCount = initial
    return {
        runningCount += increment
        return runningCount
    }
}

class SyncScheduler {
    let jobTitle: String
    var scheduledAction: (() -> Void)?

    init(jobTitle: String) {
        self.jobTitle = jobTitle
    }

    func registerAction() {
        scheduledAction = { [weak self] in
            guard let self = self else { return }
            print("Executing scheduled job: \(self.jobTitle)")
        }
    }

    deinit {
        print("SyncScheduler '\(jobTitle)' released from memory")
    }
}

func retryOperation(maxAttempts: Int, operation: () -> Bool) -> Bool {
    for attempt in 1...maxAttempts {
        if operation() {
            print("Operation succeeded on attempt \(attempt)")
            return true
        }
        print("Attempt \(attempt) failed")
    }
    return false
}

let cohort = [
    Trainee(name: "Neha", grade: 84),
    Trainee(name: "Arjun", grade: 93),
    Trainee(name: "Simran", grade: 78),
    Trainee(name: "Vikram", grade: 91)
]

let sortedShorthand = cohort.sorted { $0.grade > $1.grade }
print("Sorted (Shorthand): \(sortedShorthand.map { "\($0.name): \($0.grade)" })")

let sortedExplicit = cohort.sorted(by: { (firstTrainee: Trainee, secondTrainee: Trainee) -> Bool in
    return firstTrainee.grade > secondTrainee.grade
})
print("Sorted (Explicit): \(sortedExplicit.map { "\($0.name): \($0.grade)" })")

runSimulatedSync(taskName: "Attendance Upload") { succeeded, message in
    if succeeded {
        print("Completion Callback: \(message)")
    }
}

let nextTicketNumber = buildStepCounter(startingAt: 100, stepBy: 5)
print("Counter Call 1: \(nextTicketNumber())")
print("Counter Call 2: \(nextTicketNumber())")
print("Counter Call 3: \(nextTicketNumber())")

var scheduler: SyncScheduler? = SyncScheduler(jobTitle: "Nightly Backup")
scheduler?.registerAction()
scheduler?.scheduledAction?()
scheduler = nil

var simulatedTries = 0
let didSucceed = retryOperation(maxAttempts: 3) {
    simulatedTries += 1
    return simulatedTries == 2
}
print("Final Retry Result: \(didSucceed)")
