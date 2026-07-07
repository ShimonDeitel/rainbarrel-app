import XCTest
@testable import Rainbarrel

@MainActor
final class RainbarrelTests: XCTestCase {
    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(BarrelEntry(location: "Test", lastCleaned: "Today", diverterOK: "Good"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        let store = Store()
        store.isPro = false
        while store.entries.count < Store.freeLimit {
            store.add(BarrelEntry(location: "X", lastCleaned: "Y", diverterOK: "Z"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProEvenAtLimit() {
        let store = Store()
        store.isPro = true
        while store.entries.count < Store.freeLimit {
            store.add(BarrelEntry(location: "X", lastCleaned: "Y", diverterOK: "Z"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesEntry() {
        let store = Store()
        let entry = BarrelEntry(location: "ToDelete", lastCleaned: "Today", diverterOK: "Good")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateModifiesEntry() {
        let store = Store()
        var entry = BarrelEntry(location: "Orig", lastCleaned: "Today", diverterOK: "Good")
        store.add(entry)
        entry.location = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.location, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
