import SwiftUI

struct ProgressFormView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    let progressRecord: ProgressRecord?

    @State private var selectedStudentId: Int64 = 0
    @State private var recordDate: Date = Date()
    @State private var subject: String = ""
    @State private var topic: String = ""
    @State private var masteryLevel: MasteryLevel = .average
    @State private var score: Double = 0
    @State private var notes: String = ""
    @State private var knowledgePointType: KnowledgePointType = .weak

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治", "其他"]

    var isEditing: Bool {
        progressRecord != nil
    }

    var body: some View {
        Form {
            Section("进度信息") {
                if studentVM.students.isEmpty {
                    Text("请先添加学生")
                        .foregroundColor(.secondary)
                } else {
                    Picker("学生", selection: $selectedStudentId) {
                        Text("请选择学生").tag(Int64(0))
                        ForEach(studentVM.students) { student in
                            Text(student.name).tag(student.id ?? 0)
                        }
                    }
                }

                DatePicker("日期", selection: $recordDate, displayedComponents: .date)

                Picker("科目", selection: $subject) {
                    Text("请选择科目").tag("")
                    ForEach(subjects, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }

                TextField("知识点", text: $topic)

                Picker("掌握程度", selection: $masteryLevel) {
                    ForEach(MasteryLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }

                Picker("知识点类型", selection: $knowledgePointType) {
                    ForEach(KnowledgePointType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon).tag(type)
                    }
                }

                VStack(alignment: .leading) {
                    Text("分数: \(Int(score))")
                    Slider(value: $score, in: 0...100, step: 5)
                }
            }

            Section("备注") {
                TextField("备注", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle(isEditing ? "编辑进度" : "添加进度")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveProgressRecord()
                }
                .disabled(selectedStudentId == 0 || subject.isEmpty || topic.isEmpty)
            }
        }
        .onAppear {
            studentVM.loadStudents()
            if let record = progressRecord {
                selectedStudentId = record.studentId
                recordDate = record.recordDate
                subject = record.subject
                topic = record.topic
                masteryLevel = record.masteryLevel
                score = record.score
                notes = record.notes
            }
        }
    }

    private func saveProgressRecord() {
        var newRecord = progressRecord ?? ProgressRecord()
        newRecord.studentId = selectedStudentId
        newRecord.studentName = studentVM.getStudentName(by: selectedStudentId)
        newRecord.recordDate = recordDate
        newRecord.subject = subject
        newRecord.topic = topic
        newRecord.masteryLevel = masteryLevel
        newRecord.score = score
        newRecord.notes = notes

        viewModel.saveProgressRecord(newRecord)

        // Save knowledge point
        if let student = studentVM.students.first(where: { $0.id == selectedStudentId }) {
            KnowledgePointService.shared.saveFromProgressRecord(newRecord, student: student, type: knowledgePointType)
        }

        dismiss()
    }
}
