import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @State private var animateGraphs = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    // タイトルと説明
                    Text("禁煙に関する統計情報")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    // コンテンツセクション
                    Group {
                        // 禁煙継続日数のグラフ
                        SectionContainer(title: "禁煙の統計") {
                            CompactDayProgressGraph(
                                daysSinceQuit: viewModel.daysSinceQuit,
                                animate: animateGraphs,
                                cigarettesNotSmoked: viewModel.cigarettesNotSmoked,
                                moneySaved: viewModel.moneySaved
                            )
                        }
                        
                        // 健康改善サマリー
                        SectionContainer(title: "健康改善サマリー") {
                            HealthImprovementSummary(
                                daysSinceQuit: viewModel.daysSinceQuit,
                                hoursSinceQuit: viewModel.hoursSinceQuit,
                                cigarettesNotSmoked: viewModel.cigarettesNotSmoked,
                                moneySaved: viewModel.moneySaved,
                                currency: viewModel.currency,
                                animate: animateGraphs
                            )
                        }
                        
                        // 健康改善のタイムライン
                        SectionContainer(title: "健康改善タイムライン") {
                            CompactHealthTimelineView(
                                daysSinceQuit: viewModel.daysSinceQuit,
                                hoursSinceQuit: viewModel.hoursSinceQuit,
                                minutesSinceQuit: viewModel.minutesSinceQuit
                            )
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .onAppear {
                // 画面表示時にアニメーションを開始
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        animateGraphs = true
                    }
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 再利用可能なセクションコンテナ
struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                
                content
                    .padding()
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 5)
    }
}

// よりコンパクトな禁煙日数統計グラフ
struct CompactDayProgressGraph: View {
    let daysSinceQuit: Int
    let animate: Bool
    let cigarettesNotSmoked: Int
    let moneySaved: Double
    
    // 目標日数
    private let targetDays = 30
    
    var body: some View {
        VStack(spacing: 15) {
            // 禁煙日数とプログレスリング
            HStack(spacing: 20) {
                // 大きな数字で禁煙日数を表示
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(daysSinceQuit)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    
                    Text("禁煙継続日数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 開始日
                    let startDate = Calendar.current.date(byAdding: .day, value: -daysSinceQuit, to: Date()) ?? Date()
                    Text("開始: \(formattedStartDate(startDate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 円形プログレスバー
                ZStack {
                    // 背景の円
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.2)
                        .foregroundColor(.blue)
                    
                    // 進捗を示す円弧
                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(daysSinceQuit) / CGFloat(targetDays), 1.0) * (animate ? 1.0 : 0.0))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.easeInOut(duration: 1.0), value: animate)
                    
                    // パーセンテージ表示
                    VStack(spacing: 0) {
                        Text("\(Int(min(Double(daysSinceQuit) / Double(targetDays), 1.0) * 100))%")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("\(targetDays)日目標")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
            }
            
            // カレンダーインジケーターのコンパクト版
            if daysSinceQuit > 0 {
                VStack(alignment: .leading, spacing: 2) {
                    Text("禁煙カレンダー")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // よりコンパクトなカレンダーグリッド
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
                    LazyVGrid(columns: columns, spacing: 1) {
                        // 日付セル（最近の14日分だけ表示）
                        ForEach(-min(daysSinceQuit, 13)...0, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                            let isInQuitPeriod = offset >= -daysSinceQuit
                            let dayNumber = Calendar.current.component(.day, from: date)
                            
                            ZStack {
                                Circle()
                                    .fill(isInQuitPeriod ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                    .frame(width: 24, height: 24)
                                
                                Text("\(dayNumber)")
                                    .font(.system(size: 10))
                                    .foregroundColor(isInQuitPeriod ? .blue : .gray)
                            }
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(Double(offset + min(daysSinceQuit, 13)) * 0.02), value: animate)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
            
            // 健康状態の改善や節約金額などの簡単な情報
            HStack {
                CompactInfoTile(
                    icon: "clock.arrow.circlepath",
                    title: "次の目標まで",
                    value: "\(max(0, targetDays - daysSinceQuit))日",
                    color: .orange
                )
                
                CompactInfoTile(
                    icon: "flame.fill",
                    title: "吸わなかった本数",
                    value: "\(cigarettesNotSmoked)本",
                    color: .red
                )
                
                CompactInfoTile(
                    icon: "yensign.circle",
                    title: "節約額",
                    value: "\(Int(moneySaved))円",
                    color: .green
                )
            }
        }
    }
    
    // 日付のフォーマット
    private func formattedStartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// コンパクトな情報タイル
struct CompactInfoTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// 健康改善サマリー（よりコンパクトに）
struct HealthImprovementSummary: View {
    let daysSinceQuit: Int
    let hoursSinceQuit: Int
    let cigarettesNotSmoked: Int
    let moneySaved: Double
    let currency: String
    let animate: Bool
    
    // 健康関連の改善指標
    private var healthMetrics: [(title: String, value: String, icon: String, color: Color, description: String)] {
        return [
            (
                title: "肺機能",
                value: lungFunctionRecovery(),
                icon: "lungs.fill",
                color: .blue,
                description: "肺の機能は徐々に回復していきます"
            ),
            (
                title: "心臓病リスク",
                value: heartRiskReduction(),
                icon: "heart.fill",
                color: .red,
                description: "心血管疾患リスクの低減"
            ),
            (
                title: "タール回避",
                value: "\(tarAvoided())mg",
                icon: "exclamationmark.triangle.fill",
                color: .orange,
                description: "摂取を避けたタール量"
            ),
            (
                title: "一酸化炭素",
                value: "\(coLevels())",
                icon: "aqi.medium",
                color: .purple,
                description: "血液中の一酸化炭素レベル"
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // メトリクスを2x2のグリッドで表示
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<healthMetrics.count, id: \.self) { index in
                    let metric = healthMetrics[index]
                    
                    HStack(spacing: 8) {
                        Image(systemName: metric.icon)
                            .font(.system(size: 20))
                            .foregroundColor(metric.color)
                            .frame(width: 30)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(0.2 * Double(index)), value: animate)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(metric.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(metric.value)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(metric.color)
                            
                            Text(metric.description)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(metric.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // 総合的な健康状態の改善インジケーター
            VStack(spacing: 3) {
                HStack {
                    Text("総合的な健康改善")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(healthImprovementLevel() * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // プログレスバー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // バックグラウンド
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // フィルされたバー
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green.opacity(0.7), .green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(healthImprovementLevel()) * (animate ? 1 : 0), height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut(duration: 1.0), value: animate)
                    }
                }
                .frame(height: 6)
            }
        }
    }
    
    private func lungFunctionRecovery() -> String {
        if daysSinceQuit <= 0 {
            return "0%"
        } else if daysSinceQuit < 3 {
            return "5%"
        } else if daysSinceQuit < 7 {
            return "10%"
        } else if daysSinceQuit < 30 {
            return "20%"
        } else if daysSinceQuit < 90 {
            return "30%"
        } else if daysSinceQuit < 180 {
            return "40%"
        } else if daysSinceQuit < 365 {
            return "60%"
        } else {
            return "80%+"
        }
    }
    
    private func heartRiskReduction() -> String {
        if daysSinceQuit <= 0 {
            return "0%"
        } else if daysSinceQuit < 1 {
            return "2%"
        } else if daysSinceQuit < 7 {
            return "5%"
        } else if daysSinceQuit < 30 {
            return "10%"
        } else if daysSinceQuit < 90 {
            return "20%"
        } else if daysSinceQuit < 365 {
            return "30%"
        } else if daysSinceQuit < 730 {
            return "40%"
        } else {
            return "50%+"
        }
    }
    
    private func tarAvoided() -> Int {
        return cigarettesNotSmoked * 10 // たばこ1本あたり約10mgと仮定
    }
    
    private func coLevels() -> String {
        if hoursSinceQuit < 8 {
            return "低下中"
        } else if hoursSinceQuit < 24 {
            return "正常化"
        } else {
            return "正常"
        }
    }
    
    private func healthImprovementLevel() -> Double {
        if daysSinceQuit <= 0 {
            return 0.0
        } else if daysSinceQuit < 1 {
            return 0.05
        } else if daysSinceQuit < 3 {
            return 0.1
        } else if daysSinceQuit < 7 {
            return 0.2
        } else if daysSinceQuit < 14 {
            return 0.3
        } else if daysSinceQuit < 30 {
            return 0.4
        } else if daysSinceQuit < 90 {
            return 0.5
        } else if daysSinceQuit < 180 {
            return 0.6
        } else if daysSinceQuit < 365 {
            return 0.7
        } else if daysSinceQuit < 730 {
            return 0.8
        } else {
            return 0.9
        }
    }
}

// タイムラインをコンパクトに
struct CompactHealthTimelineView: View {
    let daysSinceQuit: Int
    let hoursSinceQuit: Int
    let minutesSinceQuit: Int
    
    // 重要なマイルストーンに絞る
    var healthMilestones: [(timeInterval: Int, unit: String, title: String, description: String, icon: String)] {
        return [
            (20, "minute", "20分後", "血圧と脈拍が正常化", "heart.fill"),
            (12, "hour", "12時間後", "血液中の一酸化炭素レベルが正常値に", "lungs.fill"),
            (24, "hour", "24時間後", "心臓発作のリスク低下開始", "heart.circle.fill"),
            (72, "hour", "72時間後", "呼吸が楽になり、エネルギー上昇", "bolt.fill"),
            (14, "day", "2週間後", "循環改善と歩行が楽に", "figure.walk"),
            (30, "day", "1ヶ月後", "肺機能30%改善、咳減少", "lungs"),
            (365, "day", "1年後", "冠動脈疾患リスク半減", "heart.text.square.fill")
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<healthMilestones.count, id: \.self) { index in
                    let milestone = healthMilestones[index]
                    let isCompleted = isTimeIntervalCompleted(milestone.timeInterval, unit: milestone.unit)
                    
                    HStack(alignment: .center, spacing: 10) {
                        // タイムラインのポイント
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 22, height: 22)
                            
                            Image(systemName: milestone.icon)
                                .foregroundColor(isCompleted ? .white : .gray)
                                .font(.system(size: 11))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestone.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(isCompleted ? .primary : .secondary)
                            
                            Text(milestone.description)
                                .font(.caption)
                                .foregroundColor(isCompleted ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        } else {
                            let timeLeft = timeLeftForMilestone(milestone.timeInterval, unit: milestone.unit)
                            Text("あと\(timeLeft)")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // コンパクトな区切り線を追加（最後のアイテムを除く）
                    if index < healthMilestones.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.vertical, 1)
                    }
                }
            }
        }
    }
    
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
    
    private func timeLeftForMilestone(_ interval: Int, unit: String) -> String {
        switch unit {
        case "minute":
            let minutesLeft = max(0, interval - minutesSinceQuit)
            return "\(minutesLeft)分"
        case "hour":
            let hoursLeft = max(0, interval - hoursSinceQuit)
            if hoursLeft >= 24 {
                return "\(hoursLeft / 24)日"
            } else {
                return "\(hoursLeft)時間"
            }
        default: // "day"
            let daysLeft = max(0, interval - daysSinceQuit)
            return "\(daysLeft)日"
        }
    }
}
