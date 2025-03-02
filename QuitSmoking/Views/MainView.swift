import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = QuitSmokingViewModel()
    @State private var showingSetupSheet = false
    
    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("ダッシュボード", systemImage: "house.fill")
                }
            
            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
            
            AchievementsView(viewModel: viewModel)
                .tabItem {
                    Label("達成", systemImage: "medal.fill")
                }
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            // 初回起動時はセットアップシートを表示
            showingSetupSheet = viewModel.isFirstLaunch
        }
        .sheet(isPresented: $showingSetupSheet) {
            SetupView(viewModel: viewModel, isPresented: $showingSetupSheet)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
