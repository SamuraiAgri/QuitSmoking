import SwiftUI

struct DateTimePickerSheet: View {
    @Binding var date: Date
    var onSave: () -> Void
    var onCancel: () -> Void
    @State private var tempDate: Date
    @State private var showError = false
    
    init(date: Binding<Date>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._date = date
        self.onSave = onSave
        self.onCancel = onCancel
        self._tempDate = State(initialValue: date.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "禁煙開始日時",
                    selection: $tempDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                if showError {
                    Text("禁煙開始日時は現在時刻より前に設定してください")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarTitle("禁煙開始日時を選択", displayMode: .inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    onCancel()
                },
                trailing: Button("保存") {
                    // 日時の検証
                    if tempDate <= Date() {
                        date = tempDate // 有効な日時のみ更新
                        onSave()
                    } else {
                        showError = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                }
            )
        }
    }
}
