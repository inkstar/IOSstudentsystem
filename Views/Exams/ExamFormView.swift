import SwiftUI

struct ExamFormView: View {
    @ObservedObject var viewModel: ExamViewModel
    @Environment(\.dismiss) private var dismiss

    let exam: Exam?
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var className: String = ""
    @State private var subject: String = ""
    @State private var totalScore: Double = 100
    @State private var notes: String = ""

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"]

    var isEditing: Bool {
        exam != nil
    }

    var body: some View {
        Form {
            Section("考试信息") {
                TextField("考试名称", text: $name)

                DatePicker("考试日期", selection: $date, displayedComponents: .date)

                Picker("科目", selection: $subject) {
                    Text("请选择科目").tag("")
                    ForEach(subjects, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }

                TextField("班级 (可选)", text: $className)

                HStack {
                    Text("总分")
                    Spacer()
                    TextField("100", value: $totalScore, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            Section("备注") {
                TextField("备注信息", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(isEditing ? "编辑考试" : "新建考试")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveExam()
                }
                .disabled(name.isEmpty || subject.isEmpty)
            }
        }
        .onAppear {
            if let exam = exam {
                name = exam.name
                date = exam.date
                className = exam.className ?? ""
                subject = exam.subject
                totalScore = exam.totalScore
                notes = exam.notes ?? ""
            }
        }
    }

    private func saveExam() {
        var newExam = exam ?? Exam()
        newExam.name = name
        newExam.date = date
        newExam.className = className.isEmpty ? nil : className
        newExam.subject = subject
        newExam.totalScore = totalScore
        newExam.notes = notes.isEmpty ? nil : notes

        viewModel.saveExam(newExam)
        dismiss()
    }
}
