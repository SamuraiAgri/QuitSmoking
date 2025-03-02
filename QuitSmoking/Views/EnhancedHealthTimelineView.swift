import SwiftUI

struct EnhancedHealthTimelineView: View {
    let daysSinceQuit: Int
    let hoursSinceQuit: Int
    let minutesSinceQuit: Int
    
    var healthMilestones: [(timeInterval: Int, unit: String, title: String, description: String, icon: String)] {
        return [
            (20, "minute", "20分後", "血圧と脈拍が通常のレベルに戻ります。", "heart.fill"),
            (12, "hour", "12時間後", "血液中の一酸化炭素レベルが正常値に戻ります。", "lungs.fill"),
            (24, "hour", "24時間後", "心臓発作のリスクが低下し始めます。", "heart.circle.fill"),
            (48, "hour", "48時間後", "味覚と嗅覚が改善し始めます。", "nose.fill"),
            (72, "hour", "72時間後", "気管支が緩み、呼吸が楽になります。エネルギーレベルが上昇します。", "bolt.fill"),
            (14, "day", "2週間後", "循環が改善し、歩行が楽になります。", "figure.walk"),
            (30, "day", "1ヶ月後", "肺機能が30%改善します。咳や息切れが減少します。", "lungs"),
            (90, "day", "3ヶ月後", "循環が改善し、肺機能が大幅に向上します。", "arrow.up.heart.fill"),
            (180, "day", "6ヶ月後", "ストレスに対処しやすくなり、感染症のリスクが減少します。", "shield.fill"),
            (365, "day", "1年後", "冠動脈疾患のリスクが半分に減少します。", "heart.text.square.fill")
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<healthMilestones.count, id: \.self) { index in
                    let milestone = healthMilestones[index]
                    let isCompleted = isTimeIntervalCompleted(milestone.timeInterval, unit: milestone.unit)
                    
                    HStack(alignment: .top, spacing: 15) {
                        // タイムラインの縦線とポイント
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: milestone.icon)
                                    .foregroundColor(isCompleted ? .white : .gray)
                                    .font(.system(size: 14))
                            }
                            
                            if index < healthMilestones.count - 1 {
                                Rectangle()
                                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 30)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(milestone.title)
                                .font(.headline)
                                .foregroundColor(isCompleted ? .primary : .secondary)
                            
                            Text(milestone.description)
                                .font(.subheadline)
                                .foregroundColor(isCompleted ? .primary : .secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if isCompleted {
                                Text("達成済み！")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                            } else {
                                let timeLeft = timeLeftForMilestone(milestone.timeInterval, unit: milestone.unit)
                                Text("あと\(timeLeft)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }
    
    // 指定された時間間隔が完了しているかチェック
    private func isTimeIntervalCompleted(_ interval: Int, unit: String) -> Bool {
        switch unit {
        case "minute":
            return minutesSinceQuit >= interval
        case "hour":
            return hoursSinceQuit >= interval
        default: // "day"
            return daysSinceQuit >= interval
        }
    }
    
    // マイルストーンまでの残り時間を計算
    private func timeLeftForMilestone(_ interval: Int, unit: String) -> String {
        switch unit {
        case "minute":
            let minutesLeft = max(0, interval - minutesSinceQuit)
            return "\(minutesLeft)分"
        case "hour":
            let hoursLeft = max(0, interval - hoursSinceQuit)
            return hoursLeft >= 24 ? "\(hoursLeft / 24)日\(hoursLeft % 24)時間" : "\(hoursLeft)時間"
        default: // "day"
            let daysLeft = max(0, interval - daysSinceQuit)
            return "\(daysLeft)日"
        }
    }
}
