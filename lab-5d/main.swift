import Foundation

final class UnsafeHitCounter: @unchecked Sendable {
    var totalHits: Int = 0

    func recordHit() {
        let current = totalHits
        totalHits = current + 1
    }
}

actor SafeHitCounter {
    private(set) var totalHits: Int = 0

    func recordHit() {
        totalHits += 1
    }

    func reset() {
        totalHits = 0
    }
}

struct HitEvent: Sendable {
    let sourceLabel: String
    let weight: Int
}

func runUnsafeConcurrentBatch(iterations: Int) async -> Int {
    let unsafeCounter = UnsafeHitCounter()
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<iterations {
            group.addTask {
                unsafeCounter.recordHit()
            }
        }
    }
    return unsafeCounter.totalHits
}

func runSafeConcurrentBatch(counter: SafeHitCounter, iterations: Int) async -> Int {
    await counter.reset()
    await withTaskGroup(of: Void.self) { group in
        for index in 0..<iterations {
            let event = HitEvent(sourceLabel: "Worker-\(index)", weight: 1)
            group.addTask {
                _ = event.weight
                await counter.recordHit()
            }
        }
    }
    return await counter.totalHits
}

func verifyRepeatedConcurrencyStressTest(rounds: Int, incrementsPerRound: Int) async {
    let sharedActorCounter = SafeHitCounter()
    for round in 1...rounds {
        let finalCount = await runSafeConcurrentBatch(counter: sharedActorCounter, iterations: incrementsPerRound)
        assert(finalCount == incrementsPerRound, "Round \(round) mismatch: expected \(incrementsPerRound), got \(finalCount)")
    }
    print("Stress Test Passed: \(rounds) rounds x \(incrementsPerRound) concurrent increments = exact count every time.")
}

let semaphore = DispatchSemaphore(value: 0)

Task {
    let targetUpdates = 2_000

    let unsafeOutcome = await runUnsafeConcurrentBatch(iterations: targetUpdates)
    print("Before Fix (Unsafe Class Counter) -> Expected: \(targetUpdates), Observed: \(unsafeOutcome)")

    let safeActor = SafeHitCounter()
    let safeOutcome = await runSafeConcurrentBatch(counter: safeActor, iterations: targetUpdates)
    print("After Fix (Safe Actor Counter) -> Expected: \(targetUpdates), Observed: \(safeOutcome)")

    await verifyRepeatedConcurrencyStressTest(rounds: 15, incrementsPerRound: 1_000)

    semaphore.signal()
}

semaphore.wait()
