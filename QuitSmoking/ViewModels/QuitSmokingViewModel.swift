import Foundation
import CoreData
import SwiftUI
import Combine

class QuitSmokingViewModel: ObservableObject {
    // 入力プロパティ
    @Published var quitDate = Date()
    @Published var cigarettesPerDay = 20
    @Published var pricePerPack = 500.0
    @Published var cigarettesPerPack = 20
    @Published var currency = "円"
    @Published var goal = "健康的な生活を取り戻す"
    
    // 計算プロパティ
    @Published var daysSinceQuit = 0
    @Published var moneySaved = 0.0
    @Published var cigarettesNotSmoked = 0
    @Published var achievements: [Achievement] = []
    
    // 状態プロパティ
    @Published var isFirstLaunch = true
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - 公開メソッド
    
    // 新しい禁煙記録を保存
    func saveNewRecord() {
        let context = DataStoreService.shared.viewContext
        let record = QuitSmokingRecord(context: context)
        
        record.startDate = quitDate
        record.cigarettesPerDay = Int16(cigarettesPerDay)
        record.pricePerPack = pricePerPack
        record.cigarettesPerPack = Int16(cigarettesPerPack)
        record.currency = currency
        record.goal = goal
        record.id = UUID()
        record.createdAt = Date()
        record.updatedAt = Date()
        
        DataStoreService.shared.saveContext()
        
        isFirstLaunch = false
        UserDefaults.standard.set(false, forKey: "QuitSmoking_FirstLaunch")
        
        scheduleMotivationalNotifications()
    }
    
    // 記録を更新
    func updateRecord() {
        let records: [QuitSmokingRecord] = DataStoreService.shared.fetchEntities("QuitSmokingRecord")
        
        guard let record = records.first else {
            saveNewRecord()
            return
        }
        
        record.startDate = quitDate
        record.cigarettesPerDay = Int16(cigarettesPerDay)
        record.pricePerPack = pricePerPack
        record.cigarettesPerPack = Int16(cigarettesPerPack)
        record.currency = currency
        record.goal = goal
        record.updatedAt = Date()
        
        DataStoreService.shared.saveContext()
    }
    
    // 現在の状況を計算
    func updateStatistics() {
        let now = Date()
        
        // 禁煙日数
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: now)
        daysSinceQuit = max(0, components.day ?? 0)
        
        // 吸わなかった本数
        cigarettesNotSmoked = daysSinceQuit * cigarettesPerDay
        
        // 節約した金額
        let packPrice = pricePerPack / Double(cigarettesPerPack)
        moneySaved = Double(cigarettesNotSmoked) * packPrice
        
        // 達成バッジをチェック
        checkAndCreateAchievements()
    }
    
    // モチベーション通知をスケジュール
    func scheduleMotivationalNotifications() {
        let notificationService = NotificationService.shared
        
        // まず既存の通知をキャンセル
        notificationService.cancelAllNotifications()
        
        // 1日後の通知
        if let oneDayDate = Calendar.current.date(byAdding: .day, value: 1, to: quitDate) {
            notificationService.scheduleNotification(
                title: "禁煙1日達成！",
                body: "素晴らしい！あなたは既に\(cigarettesPerDay)本のタバコを吸わずに済みました。この調子で続けましょう！",
                identifier: "QuitSmoking_OneDay",
                triggerDate: oneDayDate
            ) { _ in }
        }
        
        // 1週間後の通知
        if let oneWeekDate = Calendar.current.date(byAdding: .day, value: 7, to: quitDate) {
            notificationService.scheduleNotification(
                title: "禁煙1週間達成！",
                body: "一週間続けられました！あなたの体は既に回復し始めています。",
                identifier: "QuitSmoking_OneWeek",
                triggerDate: oneWeekDate
            ) { _ in }
        }
    }
    
    // MARK: - 内部メソッド
    
    private func loadData() {
        // UserDefaultsからfirstLaunchフラグを取得
        if let firstLaunch = UserDefaults.standard.object(forKey: "QuitSmoking_FirstLaunch") as? Bool {
            isFirstLaunch = firstLaunch
        }
        
        // 初回起動でない場合、保存されたデータを読み込む
        if !isFirstLaunch {
            let records: [QuitSmokingRecord] = DataStoreService.shared.fetchEntities("QuitSmokingRecord")
            
            if let record = records.first {
                quitDate = record.startDate ?? Date()
                cigarettesPerDay = Int(record.cigarettesPerDay)
                pricePerPack = record.pricePerPack
                cigarettesPerPack = Int(record.cigarettesPerPack)
                currency = record.currency ?? "円"
                goal = record.goal ?? "健康的な生活を取り戻す"
            }
            
            // 達成バッジを読み込む
            loadAchievements()
        }
        
        // 計算値を更新
        updateStatistics()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateStatistics()
        }
    }
    
    private func loadAchievements() {
        let fetchedAchievements: [Achievement] = DataStoreService.shared.fetchEntities(
            "Achievement",
            sortDescriptors: [NSSortDescriptor(key: "achievedDate", ascending: false)]
        )
        
        self.achievements = fetchedAchievements
    }
    
    private func checkAndCreateAchievements() {
        // 時間ベースの達成バッジ
        checkTimeBasedAchievements()
        
        // 節約金額ベースの達成バッジ
        checkMoneySavedAchievements()
        
        // 未喫煙本数ベースの達成バッジ
        checkCigarettesNotSmokedAchievements()
    }
    
    private func checkTimeBasedAchievements() {
        let milestones = [
            (days: 1, title: "1日達成", detail: "禁煙を1日続けました", icon: "clock.badge.checkmark"),
            (days: 3, title: "3日達成", detail: "禁煙を3日続けました", icon: "clock.badge.checkmark.fill"),
            (days: 7, title: "1週間達成", detail: "禁煙を1週間続けました", icon: "calendar.badge.checkmark")
        ]
        
        for milestone in milestones {
            if daysSinceQuit >= milestone.days && !hasAchievement(title: milestone.title) {
                createAchievement(
                    type: "time",
                    title: milestone.title,
                    detail: milestone.detail,
                    iconName: milestone.icon
                )
            }
        }
    }
    
    private func checkMoneySavedAchievements() {
        let milestones = [
            (amount: 1000.0, title: "1,000\(currency)節約", detail: "タバコを我慢して1,000\(currency)節約しました", icon: "yensign.circle"),
            (amount: 5000.0, title: "5,000\(currency)節約", detail: "タバコを我慢して5,000\(currency)節約しました", icon: "yensign.circle.fill")
        ]
        
        for milestone in milestones {
            if moneySaved >= milestone.amount && !hasAchievement(title: milestone.title) {
                createAchievement(
                    type: "money",
                    title: milestone.title,
                    detail: milestone.detail,
                    iconName: milestone.icon
                )
            }
        }
    }
    
    private func checkCigarettesNotSmokedAchievements() {
        let milestones = [
            (count: 100, title: "100本達成", detail: "100本のタバコを吸わずに済みました", icon: "lungs"),
            (count: 500, title: "500本達成", detail: "500本のタバコを吸わずに済みました", icon: "lungs.fill")
        ]
        
        for milestone in milestones {
            if cigarettesNotSmoked >= milestone.count && !hasAchievement(title: milestone.title) {
                createAchievement(
                    type: "cigarettes",
                    title: milestone.title,
                    detail: milestone.detail,
                    iconName: milestone.icon
                )
            }
        }
    }
    
    private func hasAchievement(title: String) -> Bool {
        return achievements.contains { $0.title == title }
    }
    
    private func createAchievement(type: String, title: String, detail: String, iconName: String) {
        let context = DataStoreService.shared.viewContext
        let achievement = Achievement(context: context)
        
        achievement.id = UUID()
        achievement.type = type
        achievement.title = title
        achievement.detail = detail
        achievement.iconName = iconName
        achievement.achievedDate = Date()
        
        DataStoreService.shared.saveContext()
        
        // メモリ上の配列に追加
        achievements.insert(achievement, at: 0)
    }
}
