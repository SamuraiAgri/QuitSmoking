import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 禁煙日数カード
                    VStack {
                        Text("禁煙継続日数")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("\(viewModel.daysSinceQuit)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)
                            .padding()
                        
                        Text("日")
                            .font(.title2)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 節約金額カード
                    VStack {
                        Text("節約金額")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("\(Int(viewModel.moneySaved))")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                            .padding()
                        
                        Text(viewModel.currency)
                            .font(.title2)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 吸わなかった本数カード
                    VStack {
                        Text("吸わなかった本数")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("\(viewModel.cigarettesNotSmoked)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("本")
                            .font(.title2)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 最近の達成バッジ
                    if !viewModel.achievements.isEmpty {
                        VStack(alignment: .leading) {
                            Text("最近の達成")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.achievements.prefix(3), id: \.id) { achievement in
                                HStack {
                                    Image(systemName: achievement.iconName ?? "checkmark.circle")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text(achievement.title ?? "")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text(achievement.detail ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(achievement.formattedAchievementDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("禁煙ダッシュボード")
        }
    }
}
