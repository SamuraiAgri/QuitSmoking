import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙情報を入力してください")) {
                    DatePicker("禁煙開始日", selection: $viewModel.quitDate, displayedComponents: .date)
                    
                    HStack {
                        Text("1日あたりの本数")
                        Spacer()
                        Stepper("\(viewModel.cigarettesPerDay)本", value: $viewModel.cigarettesPerDay, in: 1...100)
                    }
                    
                    HStack {
                        Text("1箱あたりの価格")
                        Spacer()
                        TextField("価格", value: $viewModel.pricePerPack, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(viewModel.currency)
                    }
                    
                    HStack {
                        Text("1箱あたりの本数")
                        Spacer()
                        Stepper("\(viewModel.cigarettesPerPack)本", value: $viewModel.cigarettesPerPack, in: 1...100)
                    }
                    
                    HStack {
                        Text("通貨単位")
                        Spacer()
                        TextField("通貨", text: $viewModel.currency)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section(header: Text("目標")) {
                    TextField("禁煙の目標を入力", text: $viewModel.goal)
                }
                
                Section {
                    Button("禁煙を始める") {
                        viewModel.saveNewRecord()
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
        }
    }
}
