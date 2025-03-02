import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.achievements.isEmpty {
                    Text("まだ達成バッジはありません。禁煙を続けると獲得できます。")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.achievements, id: \.id) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
            .navigationTitle("達成バッジ")
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: achievement.iconName ?? "checkmark.circle")
                .font(.title)
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title ?? "")
                    .font(.headline)
                
                Text(achievement.detail ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(achievement.formattedAchievementDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
