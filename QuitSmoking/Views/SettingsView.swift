import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @State private var showingDatePicker = false
    @State private var tempQuitDate = Date()
    @State private var saveConfirmation = false
    @State private var showResetConfirmation = false
    @State private var tempPriceString = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙設定")) {
                    Button(action: {
                        tempQuitDate = viewModel.quitDate
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text("禁煙開始日")
                            Spacer()
                            Text(dateFormatter.string(from: viewModel.quitDate))
                                .foregroundColor(.blue)
                        }
                    }
                    
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
                            .onAppear {
                                tempPriceString = "\(Int(viewModel.pricePerPack))"
                            }
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
                    Button("保存") {
                        // 価格の更新（TextField内の文字列をDoubleに変換）
                        if let price = Double(tempPriceString) {
                            viewModel.pricePerPack = price
                        }
                        
                        // 記録の更新
                        viewModel.updateRecord()
                        
                        // フィードバックを追加
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // 保存完了メッセージ
                        saveConfirmation = true
                        
                        // 数秒後にメッセージを消す
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            saveConfirmation = false
                        }
                        
                        // キーボードを閉じる
                        hideKeyboard()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                    
                    if saveConfirmation {
                        HStack {
                            Spacer()
                            Text("設定が保存されました")
                                .foregroundColor(.green)
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("データ管理")) {
                    Button("データをリセット") {
                        showResetConfirmation = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("設定")
            .alert(isPresented: $showResetConfirmation) {
                Alert(
                    title: Text("データをリセット"),
                    message: Text("すべての禁煙データと達成バッジがリセットされます。この操作は元に戻せません。"),
                    primaryButton: .destructive(Text("リセット")) {
                        viewModel.resetAllData()
                        // リセット成功のフィードバック
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(
                    date: $tempQuitDate,
                    onSave: {
                        viewModel.quitDate = tempQuitDate
                        viewModel.updateRecord()
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        showingDatePicker = false
                    },
                    onCancel: {
                        showingDatePicker = false
                    }
                )
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}

struct DatePickerSheet: View {
    @Binding var date: Date
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "禁煙開始日",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("禁煙開始日を選択", displayMode: .inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    onCancel()
                },
                trailing: Button("保存") {
                    onSave()
                }
            )
        }
    }
}

// キーボードを閉じるための拡張
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
