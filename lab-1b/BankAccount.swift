import Foundation

public class BankAccount {
    public let ownerName: String
    private var currentBalance: Double
    public private(set) var activityLog: [String] = []
    internal var branchCode: String = "AGRA-01"
    fileprivate var highActivityAlert: Bool = false

    public init?(ownerName: String, openingFunds: Double) {
        let cleanName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, openingFunds >= 0 else {
            return nil
        }

        self.ownerName = cleanName
        self.currentBalance = openingFunds
        self.activityLog.append("Opened account with \(openingFunds)")
    }

    public func checkBalance() -> Double {
        return currentBalance
    }

    public func deposit(_ amount: Double) {
        guard amount > 0 else {
            print("Invalid deposit (\(amount)): must be positive.")
            return
        }
        currentBalance += amount
        activityLog.append("Deposit: +\(amount) | Balance: \(currentBalance)")
        evaluateThreshold(amount)
    }

    public func withdraw(_ amount: Double) {
        guard amount > 0 else {
            print("Invalid withdrawal (\(amount)): must be positive.")
            return
        }
        guard amount <= currentBalance else {
            print("Declined withdrawal (\(amount)): exceeds available balance (\(currentBalance)).")
            return
        }
        currentBalance -= amount
        activityLog.append("Withdrawal: -\(amount) | Balance: \(currentBalance)")
        evaluateThreshold(amount)
    }

    private func evaluateThreshold(_ amount: Double) {
        if amount >= 5000 {
            highActivityAlert = true
        }
    }
}

public struct BranchCompliance {
    public init() {}

    public func verifyLimit(for account: BankAccount) {
        print("Compliance Flag (fileprivate): \(account.highActivityAlert)")
    }
}
