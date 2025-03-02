import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @Binding var isPresented: Bool
    @State private var tempPriceString = "500"
    @State private var isShowingError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false // 処理中フラグを追加
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙情報を入力してください")) {
                    DatePicker(
                        "禁煙開始日時",
                        selection: $viewModel.quitDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(DefaultDatePickerStyle())
                    
                    HStack {
                        Text("1日あたりの本数")
                        Spacer()
                        Stepper("\(viewModel.cigarettesPerDay)本", value: $viewModel.cigarettesPerDay, in: 1...100)
                    }
                    
                    HStack {
                        Text("1箱あたりの価格")
                        Spacer()
                        TextField("価格", text: $tempPriceString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .padding(5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .onChange(of: tempPriceString) { newValue in
                                if let newPrice = Double(newValue) {
                                    viewModel.pricePerPack = newPrice
                                }
                            }
                        Text(viewModel.currency)
                    }
                    
                    HStack {
                        Text("1箱あたりの本数")
                        Spacer()
                        Stepper("\(viewModel.cigarettesPerPack)本", value: $viewModel.cigarettesPerPack, in: 1...100)
                    }
                }
                
                Section {
                    Button(action: {
                        // 入力チェック
                        guard !isProcessing else { return } // 二重タップ防止
                        
                        guard let price = Double(tempPriceString), price > 0 else {
                            showError("有効な価格を入力してください")
                            return
                        }
                        
                        // 現在日時チェック
                        if !isValidDateTime(viewModel.quitDate) {
                            showError("禁煙開始日時は現在時刻より前に設定してください")
                            return
                        }
                        
                        // 処理開始
                        isProcessing = true
                        
                        // 価格の更新
                        viewModel.pricePerPack = price
                        
                        // 目標のデフォルト値を設定
                        viewModel.goal = "健康的な生活を取り戻す"
                        
                        // 記録の保存
                        viewModel.saveNewRecord()
                        
                        // フィードバック
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // シートを閉じる
                        isPresented = false
                        
                        // 処理完了
                        isProcessing = false
                    }) {
                        Text("禁煙を始める")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(isProcessing) // 処理中は無効化
                    
                    if isShowingError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
            }
            .navigationTitle("禁煙アプリの設定")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("スキップ") {
                        isPresented = false
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                // 初期値の設定
                tempPriceString = "\(Int(viewModel.pricePerPack))"
            }
        }
    }
    
    // 日時の検証 - 現在より未来の時間を禁止
    private func isValidDateTime(_ date: Date) -> Bool {
        return date <= Date()
    }
    
    // エラーを表示
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
        
        // 振動フィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // 数秒後にエラーを非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isShowingError = false
        }
    }
}
