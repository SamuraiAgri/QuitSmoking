import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: QuitSmokingViewModel
    @State private var showingDatePicker = false
    @State private var tempQuitDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙設定")) {
                    HStack {
                        Text("禁煙開始日")
                        Spacer()
                        Button(action: {
                            tempQuitDate = viewModel.quitDate
                            showingDatePicker = true
                        }) {
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
                
                Section {
                    Button("保存") {
                        viewModel.updateRecord()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker("禁煙開始日", selection: $tempQuitDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    
                    HStack {
                        Button("キャンセル") {
                            showingDatePicker = false
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("保存") {
                            viewModel.quitDate = tempQuitDate
                            showingDatePicker = false
                        }
                        .padding()
                    }
                }
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
