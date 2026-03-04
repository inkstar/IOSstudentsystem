import SwiftUI

struct LessonFormView: View {
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson?

    @State private var selectedStudentId: Int64 = 0
    @State private var lessonDate: Date = Date()
    @State private var startTime: Date = LessonFormView.date(from: "09:00")
    @State private var endTime: Date = LessonFormView.date(from: "10:00")
    @State private var subject: String = ""
    @State private var content: String = ""
    @State private var homework: String = ""
    @State private var duration: Int = 60
    @State private var status: LessonStatus = .completed
    @State private var notes: String = ""

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治", "其他"]

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

                DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)

                DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)

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
                HStack {
                    Text("时长")
                    Spacer()
                    Text("\(duration) 分钟")
                        .foregroundColor(.secondary)
                }

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
                let parsedRange = Self.parseTimeRange(from: lesson.lessonTime)
                startTime = parsedRange.start
                endTime = parsedRange.end
                subject = lesson.subject
                content = lesson.content
                homework = lesson.homework
                duration = lesson.duration
                status = lesson.status
                notes = lesson.notes
            }
            normalizeTimeRange(adjustEndIfNeeded: true)
        }
        .onChange(of: startTime) { _ in
            normalizeTimeRange(adjustEndIfNeeded: true)
        }
        .onChange(of: endTime) { _ in
            normalizeTimeRange(adjustEndIfNeeded: false)
        }
    }

    private func saveLesson() {
        var newLesson = lesson ?? Lesson()
        newLesson.studentId = selectedStudentId
        newLesson.studentName = studentVM.getStudentName(by: selectedStudentId)
        newLesson.lessonDate = lessonDate
        newLesson.lessonTime = "\(Self.timeString(from: startTime))-\(Self.timeString(from: endTime))"
        newLesson.subject = subject
        newLesson.content = content
        newLesson.homework = homework
        newLesson.duration = duration
        newLesson.status = status
        newLesson.notes = notes

        viewModel.saveLesson(newLesson)
        dismiss()
    }

    private func normalizeTimeRange(adjustEndIfNeeded: Bool) {
        let startMinutes = Self.minutes(from: startTime)
        var endMinutes = Self.minutes(from: endTime)

        if adjustEndIfNeeded, endMinutes <= startMinutes {
            endMinutes = min(startMinutes + 30, 23 * 60 + 59)
            endTime = Self.date(from: Self.timeString(from: endMinutes))
        }

        duration = max(endMinutes - startMinutes, 1)
    }

    private static func parseTimeRange(from value: String) -> (start: Date, end: Date) {
        let normalized = value.replacingOccurrences(of: " ", with: "")
        let parts = normalized.split(separator: "-", maxSplits: 1).map(String.init)
        if parts.count == 2 {
            return (date(from: parts[0]), date(from: parts[1]))
        }
        let start = minutes(from: normalized)
        let end = min(start + 60, 23 * 60 + 59)
        return (date(from: timeString(from: start)), date(from: timeString(from: end)))
    }

    private static func minutes(from time: String) -> Int {
        let parts = time.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute) else {
            return 0
        }
        return hour * 60 + minute
    }

    private static func minutes(from time: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private static func timeString(from minutes: Int) -> String {
        let safe = max(0, min(23 * 60 + 59, minutes))
        let hour = safe / 60
        let minute = safe % 60
        return String(format: "%02d:%02d", hour, minute)
    }

    private static func timeString(from date: Date) -> String {
        timeString(from: minutes(from: date))
    }

    private static func date(from time: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time) ?? Date()
    }
}
