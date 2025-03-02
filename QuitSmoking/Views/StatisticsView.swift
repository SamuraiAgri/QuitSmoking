import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 時間の経過によるグラフ（プレースホルダー）
                    Text("禁煙継続日数")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("グラフ表示エリア")
                                .foregroundColor(.gray)
                        )
                    
                    // 節約金額のグラフ（プレースホルダー）
                    Text("節約金額の推移")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("グラフ表示エリア")
                                .foregroundColor(.gray)
                        )
                    
                    // 健康改善の進捗タイムライン
                    HealthTimelineView(daysSinceQuit: viewModel.daysSinceQuit)
                }
                .padding()
            }
            .navigationTitle("禁煙の統計")
        }
    }
}

struct HealthTimelineView: View {
    let daysSinceQuit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("健康改善タイムライン")
                .font(.headline)
                .padding(.bottom, 5)
            
            Group {
                TimelineItem(
                    time: "20分後",
                    description: "血圧と脈拍が通常のレベルに戻ります。",
                    isCompleted: daysSinceQuit > 0
                )
                
                TimelineItem(
                    time: "12時間後",
                    description: "血液中の一酸化炭素レベルが正常値に戻ります。",
                    isCompleted: daysSinceQuit > 0
                )
                
                TimelineItem(
                    time: "24時間後",
                    description: "心臓発作のリスクが低下し始めます。",
                    isCompleted: daysSinceQuit >= 1
                )
                
                TimelineItem(
                    time: "48時間後",
                    description: "味覚と嗅覚が改善し始めます。",
                    isCompleted: daysSinceQuit >= 2
                )
                
                TimelineItem(
                    time: "72時間後",
                    description: "気管支が緩み、呼吸が楽になります。エネルギーレベルが上昇します。",
                    isCompleted: daysSinceQuit >= 3
                )
                
                TimelineItem(
                    time: "2週間〜3ヶ月後",
                    description: "循環が改善します。肺機能が30%改善します。",
                    isCompleted: daysSinceQuit >= 14
                )
                
                TimelineItem(
                    time: "1年後",
                    description: "冠動脈疾患のリスクが半分に減少します。",
                    isCompleted: daysSinceQuit >= 365
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TimelineItem: View {
    let time: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // タイムラインの縦線とポイント
            VStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.5))
                    .frame(width: 12, height: 12)
                
                if time != "1年後" { // 最後のアイテムには線を引かない
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // テキストが折り返されるようにする
            }
            .padding(.bottom, 10)
        }
    }
}
