import SwiftUI

struct LessonFormView: View {
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson?

    @State private var selectedStudentId: Int64 = 0
    @State private var lessonDate: Date = Date()
    @State private var lessonTime: String = "09:00"
    @State private var subject: String = ""
    @State private var content: String = ""
    @State private var homework: String = ""
    @State private var duration: Int = 60
    @State private var status: LessonStatus = .completed
    @State private var notes: String = ""

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治", "其他"]
    private let times = generateTimes()

    var isEditing: Bool {
        lesson != nil
    }

    var body: some View {
        Form {
            Section("课程信息") {
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

                DatePicker("日期", selection: $lessonDate, displayedComponents: .date)

                Picker("时间", selection: $lessonTime) {
                    ForEach(times, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }

                Picker("科目", selection: $subject) {
                    Text("请选择科目").tag("")
                    ForEach(subjects, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }

                TextField("课程内容", text: $content, axis: .vertical)
                    .lineLimit(3...6)

                TextField("作业", text: $homework, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("其他信息") {
                Stepper("时长: \(duration) 分钟", value: $duration, in: 30...180, step: 30)

                Picker("状态", selection: $status) {
                    ForEach(LessonStatus.allCases, id: \.self) { s in
                        Text(s.displayName).tag(s)
                    }
                }

                TextField("备注", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle(isEditing ? "编辑课程" : "添加课程")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveLesson()
                }
                .disabled(selectedStudentId == 0 || subject.isEmpty)
            }
        }
        .onAppear {
            studentVM.loadStudents()
            if let lesson = lesson {
                selectedStudentId = lesson.studentId
                lessonDate = lesson.lessonDate
                lessonTime = lesson.lessonTime
                subject = lesson.subject
                content = lesson.content
                homework = lesson.homework
                duration = lesson.duration
                status = lesson.status
                notes = lesson.notes
            }
        }
    }

    private func saveLesson() {
        var newLesson = lesson ?? Lesson()
        newLesson.studentId = selectedStudentId
        newLesson.studentName = studentVM.getStudentName(by: selectedStudentId)
        newLesson.lessonDate = lessonDate
        newLesson.lessonTime = lessonTime
        newLesson.subject = subject
        newLesson.content = content
        newLesson.homework = homework
        newLesson.duration = duration
        newLesson.status = status
        newLesson.notes = notes

        viewModel.saveLesson(newLesson)
        dismiss()
    }

    private static func generateTimes() -> [String] {
        var times: [String] = []
        for hour in 8...20 {
            for minute in [0, 30] {
                times.append(String(format: "%02d:%02d", hour, minute))
            }
        }
        return times
    }
}
