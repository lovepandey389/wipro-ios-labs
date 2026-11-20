import Foundation

print("=== Initializing Account ===")
if let badAccount = BankAccount(ownerName: "   ", openingFunds: -200) {
    print("Unexpectedly created: \(badAccount.ownerName)")
} else {
    print("Blocked invalid account creation successfully.")
}

guard let myAccount = BankAccount(ownerName: "Love Pandey", openingFunds: 1500.0) else {
    fatalError("Could not set up account")
}

print("\n=== Testing Deposits & Withdrawals ===")
myAccount.deposit(0)
myAccount.deposit(-50)
myAccount.deposit(750)

myAccount.withdraw(5000)
myAccount.withdraw(-10)
myAccount.withdraw(450)

print("Verified Balance: \(myAccount.checkBalance())")

print("\n=== Verifying Access Control Levels ===")
print("Owner (public): \(myAccount.ownerName)")
print("Branch Code (internal): \(myAccount.branchCode)")

let reviewer = BranchCompliance()
reviewer.verifyLimit(for: myAccount)

print("\n=== Read-Only Audit Trail ===")
for record in myAccount.activityLog {
    print("- \(record)")
}
