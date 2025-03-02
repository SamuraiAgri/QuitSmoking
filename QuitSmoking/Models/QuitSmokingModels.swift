import Foundation
import CoreData

extension QuitSmokingRecord {
    var formattedQuitDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: startDate ?? Date())
    }
}

extension Achievement {
    var formattedAchievementDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: achievedDate ?? Date())
    }
}
