import Foundation

struct BarrelEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var location: String
    var lastCleaned: String
    var diverterOK: String
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), location: String, lastCleaned: String, diverterOK: String, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.location = location
        self.lastCleaned = lastCleaned
        self.diverterOK = diverterOK
        self.notes = notes
        self.createdAt = createdAt
    }
}
