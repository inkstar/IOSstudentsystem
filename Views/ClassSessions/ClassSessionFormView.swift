import SwiftUI

struct ClassSessionFormView: View {
    @ObservedObject var viewModel: ClassSessionViewModel
    @Environment(\.dismiss) private var dismiss

    let session: ClassSession?
    @State private var className: String = ""
    @State private var date: Date = Date()
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var subject: String = ""
    @State private var topic: String = ""
    @State private var notes: String = ""

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"]

    var isEditing: Bool {
        session != nil
    }

    var body: some View {
        Form {
            Section("课堂信息") {
                TextField("班级名称", text: $className)

                DatePicker("上课日期", selection: $date, displayedComponents: .date)

                HStack {
                    TextField("开始时间 (如 09:00)", text: $startTime)
                    Text("-")
                    TextField("结束时间 (如 10:30)", text: $endTime)
                }

                Picker("科目", selection: $subject) {
                    Text("请选择科目").tag("")
                    ForEach(subjects, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }

                TextField("本次主题 (可选)", text: $topic)
            }

            Section("备注") {
                TextField("备注信息", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(isEditing ? "编辑课堂记录" : "新建课堂记录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveSession()
                }
                .disabled(className.isEmpty || subject.isEmpty)
            }
        }
        .onAppear {
            if let session = session {
                className = session.className
                date = session.date
                startTime = session.startTime
                endTime = session.endTime
                subject = session.subject
                topic = session.topic ?? ""
                notes = session.notes ?? ""
            }
        }
    }

    private func saveSession() {
        var newSession = session ?? ClassSession()
        newSession.className = className
        newSession.date = date
        newSession.startTime = startTime
        newSession.endTime = endTime
        newSession.subject = subject
        newSession.topic = topic.isEmpty ? nil : topic
        newSession.notes = notes.isEmpty ? nil : notes

        viewModel.saveSession(newSession)
        dismiss()
    }
}
