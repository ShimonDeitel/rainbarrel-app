import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [BarrelEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Rainbarrel", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
        if entries.isEmpty {
            seed()
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(_ entry: BarrelEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: BarrelEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: BarrelEntry) {
        entries.removeAll(where: { $0.id == entry.id })
        save()
    }

    private func seed() {
        entries = [
            BarrelEntry(location: "Front", lastCleaned: "Recently checked", diverterOK: "Good", notes: "Seed entry"),
            BarrelEntry(location: "Back", lastCleaned: "Last month", diverterOK: "Needs attention", notes: "Seed entry"),
            BarrelEntry(location: "Side", lastCleaned: "Two months ago", diverterOK: "Good", notes: "Seed entry"),
        ]
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([BarrelEntry].self, from: data) else { return }
        entries = decoded
    }
}
