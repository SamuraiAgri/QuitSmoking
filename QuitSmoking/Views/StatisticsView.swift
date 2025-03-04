import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @State private var animateGraphs = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 禁煙継続日数のグラフ
                    VStack(alignment: .leading, spacing: 10) {
                        Text("禁煙の統計")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            EnhancedDayProgressGraph(daysSinceQuit: viewModel.daysSinceQuit, animate: animateGraphs)
                                .padding()
                        }
                        .frame(height: 440)
                        .padding(.horizontal)
                    }
                    
                    // 節約金額の推移グラフを健康影響サマリーに置き換え
                    VStack(alignment: .leading, spacing: 10) {
                        Text("健康改善サマリー")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            HealthImprovementSummary(
                                daysSinceQuit: viewModel.daysSinceQuit,
                                hoursSinceQuit: viewModel.hoursSinceQuit,
                                cigarettesNotSmoked: viewModel.cigarettesNotSmoked,
                                moneySaved: viewModel.moneySaved,
                                currency: viewModel.currency,
                                animate: animateGraphs
                            )
                            .padding()
                        }
                        .frame(height: 350)
                        .padding(.horizontal)
                    }
                    
                    // 健康改善のタイムライン
                    VStack(alignment: .leading, spacing: 10) {
                        Text("健康改善タイムライン")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            EnhancedHealthTimelineView(
                                daysSinceQuit: viewModel.daysSinceQuit,
                                hoursSinceQuit: viewModel.hoursSinceQuit,
                                minutesSinceQuit: viewModel.minutesSinceQuit
                            )
                            .padding()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
            .navigationTitle("") // タイトルを空にしてナビゲーションバーのスペースを減らす
            .navigationBarHidden(true) // ナビゲーションバーを非表示にする
        }
    }
}

// 新しいコンポーネント: 健康改善サマリー
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
                title: "肺機能の回復",
                value: lungFunctionRecovery(),
                icon: "lungs.fill",
                color: .blue,
                description: "禁煙後、肺の機能は徐々に回復していきます。"
            ),
            (
                title: "心臓病リスク低減",
                value: heartRiskReduction(),
                icon: "heart.fill",
                color: .red,
                description: "禁煙後、心臓発作などの心血管疾患のリスクが段階的に低下します。"
            ),
            (
                title: "タール摂取回避",
                value: "\(tarAvoided())mg",
                icon: "exclamationmark.triangle.fill",
                color: .orange,
                description: "たばこ1本あたり約10mgのタールを含みます。"
            ),
            (
                title: "節約金額",
                value: "\(Int(moneySaved))\(currency)",
                icon: "yensign.circle.fill",
                color: .green,
                description: "タバコを買わずに節約できた金額です。"
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("禁煙によるポジティブな変化")
                .font(.headline)
                .padding(.bottom, 5)
            
            // メトリクスを2x2のグリッドで表示
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(0..<healthMetrics.count, id: \.self) { index in
                    let metric = healthMetrics[index]
                    
                    VStack(spacing: 8) {
                        Image(systemName: metric.icon)
                            .font(.system(size: 24))
                            .foregroundColor(metric.color)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(0.2 * Double(index)), value: animate)
                        
                        Text(metric.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(metric.value)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(metric.color)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(0.3 * Double(index)), value: animate)
                        
                        Text(metric.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 5)
                    }
                    .padding(10)
                    .background(metric.color.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            // 総合的な健康状態の改善インジケーター
            VStack(spacing: 5) {
                Text("総合的な健康改善")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 0) {
                    ForEach(0..<10, id: \.self) { index in
                        let fillLevel = healthImprovementLevel()
                        Rectangle()
                            .fill(index < Int(fillLevel * 10) ? Color.green : Color.gray.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(0.05 * Double(index)), value: animate)
                    }
                }
                
                Text("\(Int(healthImprovementLevel() * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
        }
    }
    
    // 肺機能の回復率を計算
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
            return "80%以上"
        }
    }
    
    // 心臓病リスクの減少率を計算
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
            return "50%以上"
        }
    }
    
    // 避けられたタールの量を計算（mg単位、たばこ1本あたり約10mgと仮定）
    private func tarAvoided() -> Int {
        return cigarettesNotSmoked * 10
    }
    
    // 総合的な健康改善レベル（0.0〜1.0）
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

// 既存のEnhancedDayProgressGraphは変更なし

struct EnhancedDayProgressGraph: View {
    let daysSinceQuit: Int
    let animate: Bool
    
    // プログレスリングのためのアニメーション値
    @State private var progressValue: Double = 0
    
    // 目標日数 (初期値は30日)
    private let targetDays = 30
    
    // 日付フォーマッタ
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 目標に対する進捗を表示
            HStack(spacing: 25) {
                // 大きな数字で禁煙日数を表示 - 5桁まで対応
                Text("\(daysSinceQuit)")
                    .font(.system(size: daysSinceQuit >= 10000 ? 60 : 72, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: 150, alignment: .center) // 幅を増やして5桁対応
                    .minimumScaleFactor(0.5) // テキストが収まるように自動調整
                    .lineLimit(1)
                
                // 円形プログレスバー
                ZStack {
                    // 背景の円
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.2)
                        .foregroundColor(.blue)
                    
                    // 進捗を示す円弧
                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(daysSinceQuit) / CGFloat(targetDays), 1.0) * (animate ? 1.0 : 0.0))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.easeInOut(duration: 1.0), value: animate)
                    
                    // パーセンテージ表示
                    VStack(spacing: 2) {
                        Text("\(Int(min(Double(daysSinceQuit) / Double(targetDays), 1.0) * 100))%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("\(targetDays)日目標")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 100, height: 100)
            }
            .padding(.top, 5)
            
            // 説明ラベル
            Text("禁煙継続日数")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, -10) // 少し上に寄せる
            
            // 禁煙を始めた日付を表示
            let startDate = Calendar.current.date(byAdding: .day, value: -daysSinceQuit, to: Date()) ?? Date()
            Text("開始日: \(formattedStartDate(startDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, -5) // 少し上に寄せる
            
            // カレンダー風の最近の禁煙日表示
            if daysSinceQuit > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text("最近の禁煙記録")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 5)
                        .padding(.bottom, 3)
                    
                    // カレンダーグリッド
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
                    LazyVGrid(columns: columns, spacing: 2) {
                        // 曜日ヘッダー
                        Group {
                            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(day == "日" ? .red : .secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // 日付セル
                        ForEach(-min(daysSinceQuit + 6, 41)...0, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                            let isInQuitPeriod = offset >= -daysSinceQuit
                            let dayNumber = Calendar.current.component(.day, from: date)
                            
                            ZStack {
                                // 日付の背景
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isInQuitPeriod ? Color.blue.opacity(0.2) : Color.clear)
                                    .frame(height: 22)
                                
                                // 日付のテキスト
                                Text("\(dayNumber)")
                                    .font(.system(size: 11))
                                    .foregroundColor(isInQuitPeriod ? .blue : .secondary)
                            }
                            .opacity(animate ? 1 : 0)
                            .animation(.easeIn.delay(Double(offset + min(daysSinceQuit + 6, 41)) * 0.02), value: animate)
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
            }
            
            // 健康状態の改善や節約金額などの簡単な情報
            HStack(spacing: 15) {
                InfoTile(
                    icon: "clock.arrow.circlepath",
                    title: "目標まで",
                    value: "\(max(0, targetDays - daysSinceQuit))日",
                    color: .orange
                )
                
                InfoTile(
                    icon: "heart.fill",
                    title: "健康改善",
                    value: healthRecoveryPercentage(),
                    color: .green
                )
            }
            .padding(.top, 5)
        }
    }
    
    // 日付のフォーマット
    private func formattedStartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // 健康回復の割合を計算（単純な例）
    private func healthRecoveryPercentage() -> String {
        if daysSinceQuit <= 0 {
            return "0%"
        } else if daysSinceQuit < 3 {
            return "10%"
        } else if daysSinceQuit < 7 {
            return "25%"
        } else if daysSinceQuit < 30 {
            return "50%"
        } else if daysSinceQuit < 90 {
            return "75%"
        } else {
            return "90%"
        }
    }
}

// 情報タイルコンポーネント（変更なし）
struct InfoTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
