import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @Binding var isPresented: Bool
    @State private var tempPriceString = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙情報を入力してください")) {
                    DatePicker("禁煙開始日", selection: $viewModel.quitDate, in: ...Date(), displayedComponents: .date)
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
                
                Section(header: Text("目標")) {
                    TextField("禁煙の目標を入力", text: $viewModel.goal)
                }
                
                Section {
                    Button("禁煙を始める") {
                        // 価格の更新
                        if let price = Double(tempPriceString) {
                            viewModel.pricePerPack = price
                        }
                        
                        viewModel.saveNewRecord()
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
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
        }
    }
}
