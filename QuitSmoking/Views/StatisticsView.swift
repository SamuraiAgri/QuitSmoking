import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @State private var animateGraphs = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) { // スペースを増やして余裕を持たせる
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
                        .frame(height: 440) // より多くのスペースを確保
                        .padding(.horizontal)
                    }
                    
                    // 節約金額のグラフ
                    VStack(alignment: .leading, spacing: 10) {
                        Text("節約金額の推移")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            EnhancedSavingsGraph(
                                moneySaved: viewModel.moneySaved,
                                days: viewModel.daysSinceQuit,
                                cigarettesPerDay: viewModel.cigarettesPerDay,
                                pricePerPack: viewModel.pricePerPack,
                                cigarettesPerPack: viewModel.cigarettesPerPack,
                                currency: viewModel.currency,
                                animate: animateGraphs
                            )
                            .padding()
                        }
                        .frame(height: 350) // 高さを増やして余裕を持たせる
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
                            
                            EnhancedHealthTimelineView(daysSinceQuit: viewModel.daysSinceQuit)
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

// 情報タイルコンポーネント
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

struct EnhancedSavingsGraph: View {
    let moneySaved: Double
    let days: Int
    let cigarettesPerDay: Int
    let pricePerPack: Double
    let cigarettesPerPack: Int
    let currency: String
    let animate: Bool
    
    // 将来予測の日数
    private let futurePredictionDays = 30
    
    // 日付フォーマッタ
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }
    
    // 一日あたりの節約額を計算
    private var savingsPerDay: Double {
        let cigarettesPrice = pricePerPack / Double(cigarettesPerPack)
        return cigarettesPrice * Double(cigarettesPerDay)
    }
    
    // グラフのポイントを計算
    private func calculatePoints(in size: CGSize) -> [CGPoint] {
        let width = size.width
        let height = size.height
        let totalDays = days + futurePredictionDays
        let pointDistance = width / CGFloat(totalDays > 1 ? totalDays - 1 : 1)
        
        var points: [CGPoint] = []
        
        // 過去の実際の節約額
        for i in 0...days {
            let x = CGFloat(i) * pointDistance
            let actualSaving = Double(i) * savingsPerDay
            let y = height - CGFloat(actualSaving / (savingsPerDay * Double(totalDays))) * height
            points.append(CGPoint(x: x, y: y))
        }
        
        // 将来の予測節約額
        if days > 0 {
            for i in 1...futurePredictionDays {
                let x = CGFloat(days + i) * pointDistance
                let predictedSaving = moneySaved + Double(i) * savingsPerDay
                let y = height - CGFloat(predictedSaving / (savingsPerDay * Double(totalDays))) * height
                points.append(CGPoint(x: x, y: y))
            }
        }
        
        return points
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    // グラフの背景グリッド
                    VStack(spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    
                    // 左側のY軸ラベル
                    VStack(alignment: .leading) {
                        ForEach(0..<5) { i in
                            if i == 0 {
                                Text("0\(currency)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            } else {
                                let value = Int(Double(i) * savingsPerDay * Double(days + futurePredictionDays) / 4.0)
                                Text("\(value)\(currency)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 節約グラフ
                    if days > 0 {
                        let pathPoints = calculatePoints(in: CGSize(width: geometry.size.width - 50, height: geometry.size.height - 100))
                        
                        ZStack {
                            // 実際の節約グラフ（塗りつぶし）
                            Path { path in
                                guard pathPoints.count > 1 else { return }
                                
                                let cutoffIndex = min(days, pathPoints.count - 1)
                                
                                path.move(to: CGPoint(x: pathPoints[0].x, y: geometry.size.height - 40))
                                path.addLine(to: pathPoints[0])
                                
                                for i in 1...cutoffIndex {
                                    path.addLine(to: pathPoints[i])
                                }
                                
                                path.addLine(to: CGPoint(x: pathPoints[cutoffIndex].x, y: geometry.size.height - 40))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green.opacity(0.7), .green.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(animate ? 1 : 0)
                            .animation(.easeInOut(duration: 1.0), value: animate)
                            
                            // 実際の節約ライン
                            Path { path in
                                guard pathPoints.count > 1 else { return }
                                
                                let cutoffIndex = min(days, pathPoints.count - 1)
                                
                                path.move(to: pathPoints[0])
                                for i in 1...cutoffIndex {
                                    path.addLine(to: pathPoints[i])
                                }
                            }
                            .trim(from: 0, to: animate ? 1 : 0)
                            .stroke(Color.green, lineWidth: 3)
                            .animation(.easeInOut(duration: 1.5), value: animate)
                            
                            // 将来予測のライン
                            if days > 0 && pathPoints.count > days + 1 {
                                Path { path in
                                    let startIndex = min(days, pathPoints.count - 1)
                                    path.move(to: pathPoints[startIndex])
                                    
                                    for i in startIndex+1..<pathPoints.count {
                                        path.addLine(to: pathPoints[i])
                                    }
                                }
                                .trim(from: 0, to: animate ? 1 : 0)
                                .stroke(Color.green.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                                .animation(.easeInOut(duration: 1.5).delay(1.0), value: animate)
                            }
                            
                            // X軸の月ラベル
                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach(0..<4) { i in
                                    let date = Calendar.current.date(byAdding: .day, value: i * (days + futurePredictionDays) / 3, to: Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()) ?? Date()
                                    
                                    Text(monthFormatter.string(from: date))
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    
                                    if i < 3 {
                                        Spacer()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, -30)
                            .padding(.horizontal, 25)
                        }
                        .padding(.top, 25)
                        .padding(.bottom, 40)
                        .padding(.horizontal, 25)
                    } else {
                        // 初期状態のメッセージ
                        VStack {
                            Text("禁煙を始めるとグラフが表示されます")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                }
                
                // グラフと金額表示の間にスペースを追加
                Spacer()
                    .frame(height: 20)
                
                // 節約金額表示
                if days > 0 {
                    VStack(spacing: 5) {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("現在の節約額")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(moneySaved))\(currency)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5) // 大きな金額でも調整
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("1ヶ月後の予測額")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(moneySaved + savingsPerDay * 30))\(currency)")
                                    .font(.headline)
                                    .foregroundColor(.green.opacity(0.7))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5) // 大きな金額でも調整
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // グラフの凡例
                HStack {
                    HStack {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 15, height: 3)
                        
                        Text("実際の節約額")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Rectangle()
                            .fill(Color.green.opacity(0.5))
                            .frame(width: 15, height: 3)
                            .overlay(
                                Rectangle()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                                    .foregroundColor(.green.opacity(0.5))
                            )
                        
                        Text("予測節約額")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
    }
}

struct EnhancedHealthTimelineView: View {
    let daysSinceQuit: Int
    
    var healthMilestones: [(days: Int, title: String, description: String, icon: String)] {
        return [
            (0, "20分後", "血圧と脈拍が通常のレベルに戻ります。", "heart.fill"),
            (0, "12時間後", "血液中の一酸化炭素レベルが正常値に戻ります。", "lungs.fill"),
            (1, "24時間後", "心臓発作のリスクが低下し始めます。", "heart.circle.fill"),
            (2, "48時間後", "味覚と嗅覚が改善し始めます。", "nose.fill"),
            (3, "72時間後", "気管支が緩み、呼吸が楽になります。エネルギーレベルが上昇します。", "bolt.fill"),
            (14, "2週間後", "循環が改善し、歩行が楽になります。", "figure.walk"),
            (30, "1ヶ月後", "肺機能が30%改善します。咳や息切れが減少します。", "lungs"),
            (90, "3ヶ月後", "循環が改善し、肺機能が大幅に向上します。", "arrow.up.heart.fill"),
            (180, "6ヶ月後", "ストレスに対処しやすくなり、感染症のリスクが減少します。", "shield.fill"),
            (365, "1年後", "冠動脈疾患のリスクが半分に減少します。", "heart.text.square.fill")
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<healthMilestones.count, id: \.self) { index in
                    let milestone = healthMilestones[index]
                    let isCompleted = daysSinceQuit >= milestone.days
                    
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
                                let daysLeft = milestone.days - daysSinceQuit
                                Text("あと\(daysLeft)日")
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
}
