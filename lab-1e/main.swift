import Foundation

struct ModuleBlueprint {
    var title: String
    var creditHours: Int
}

class CohortCoordinator {
    var coordinatorName: String
    var activeSection: String

    init(coordinatorName: String, activeSection: String) {
        self.coordinatorName = coordinatorName
        self.activeSection = activeSection
    }

    deinit {
        print("CohortCoordinator \(coordinatorName) released from memory")
    }
}

class Mentor {
    let fullName: String
    var assignedRoom: LectureHall?

    init(fullName: String) {
        self.fullName = fullName
    }

    deinit {
        print("Mentor \(fullName) deallocated")
    }
}

class LectureHall {
    let hallCode: String
    weak var primaryMentor: Mentor?

    init(hallCode: String) {
        self.hallCode = hallCode
    }

    deinit {
        print("LectureHall \(hallCode) deallocated")
    }
}

class SessionTracker {
    let sessionLabel: String
    var completionHandler: (() -> Void)?

    init(sessionLabel: String) {
        self.sessionLabel = sessionLabel
    }

    func configureSafeCallback() {
        completionHandler = { [weak self] in
            guard let self = self else { return }
            print("Completed tracking for \(self.sessionLabel)")
        }
    }

    deinit {
        print("SessionTracker \(sessionLabel) deallocated")
    }
}

var originalModule = ModuleBlueprint(title: "Swift Foundations", creditHours: 4)
var copiedModule = originalModule
copiedModule.title = "Advanced Concurrency"
print("Original Struct: \(originalModule.title) | Copied Struct: \(copiedModule.title)")

let leadCoordinator = CohortCoordinator(coordinatorName: "Ananya", activeSection: "Batch A")
let sharedCoordinator = leadCoordinator
sharedCoordinator.activeSection = "Batch B"
print("Lead Class Ref: \(leadCoordinator.activeSection) | Shared Class Ref: \(sharedCoordinator.activeSection)")

var mentorInstance: Mentor? = Mentor(fullName: "Dr. Verma")
var hallInstance: LectureHall? = LectureHall(hallCode: "Room 302")
mentorInstance?.assignedRoom = hallInstance
hallInstance?.primaryMentor = mentorInstance

mentorInstance = nil
hallInstance = nil

var tracker: SessionTracker? = SessionTracker(sessionLabel: "ARC Lab Evaluation")
tracker?.configureSafeCallback()
tracker?.completionHandler?()
tracker = nil
