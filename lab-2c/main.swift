import Foundation

protocol Displayable {
    var summaryText: String { get }
    func renderLine() -> String
}

struct Student: Displayable {
    let rollId: String
    let fullName: String

    var summaryText: String {
        return "\(rollId) - \(fullName)"
    }

    func renderLine() -> String {
        return "[Student] \(summaryText)"
    }
}

struct Course: Displayable {
    let code: String
    let title: String

    var summaryText: String {
        return "\(code): \(title)"
    }

    func renderLine() -> String {
        return "[Course] \(summaryText)"
    }
}

extension String {
    var wordCount: Int {
        return self.split { $0.isWhitespace }.count
    }

    func trimmedAndTitled() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }
}

protocol InspectableContainer {
    var itemCount: Int { get }
}

struct Stack<T>: InspectableContainer {
    private var storage: [T] = []

    var isEmpty: Bool {
        return storage.isEmpty
    }

    var itemCount: Int {
        return storage.count
    }

    mutating func push(_ item: T) {
        storage.append(item)
    }

    mutating func pop() -> T? {
        return storage.popLast()
    }

    func peek() -> T? {
        return storage.last
    }
}

func formatAllItems<Item: Displayable>(_ items: [Item]) -> [String] {
    return items.map { $0.renderLine() }
}

struct UnformattedNote {
    let body: String
}

let learner = Student(rollId: "W101", fullName: "Love Pandey")
let subject = Course(code: "IOS-203", title: "Protocols and Generics")

assert(learner.summaryText == "W101 - Love Pandey")
assert(subject.renderLine() == "[Course] IOS-203: Protocols and Generics")

let sampleHeadline = "  swift protocol oriented programming  "
assert(sampleHeadline.wordCount == 4)
assert(sampleHeadline.trimmedAndTitled() == "Swift Protocol Oriented Programming")

var numberStack = Stack<Int>()
assert(numberStack.isEmpty == true)
numberStack.push(10)
numberStack.push(25)
assert(numberStack.peek() == 25)
assert(numberStack.itemCount == 2)
assert(numberStack.pop() == 25)

var labelStack = Stack<String>()
labelStack.push("Alpha")
labelStack.push("Beta")
assert(labelStack.itemCount == 2)
assert(labelStack.pop() == "Beta")

let formattedStudents = formatAllItems([learner])
print("Formatted Output: \(formattedStudents)")
print("All 8 assertions passed successfully.")
