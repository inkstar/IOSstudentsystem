import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var studentVM: StudentViewModel
    @StateObject private var lessonVM = LessonViewModel()
    @State private var showingEditSheet = false

    var body: some View {
        List {
            Section("课程信息") {
                HStack {
                    Text("科目")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lesson.subject)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("日期")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatDate(lesson.lessonDate))
                }

                HStack {
                    Text("时间")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lesson.lessonTime)
                }

                HStack {
                    Text("时长")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(lesson.duration) 分钟")
                }

                HStack {
                    Text("状态")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lesson.status.displayName)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
            }

            Section("课程内容") {
                if !lesson.content.isEmpty {
                    Text(lesson.content)
                } else {
                    Text("无")
                        .foregroundColor(.secondary)
                }
            }

            Section("作业") {
                if !lesson.homework.isEmpty {
                    Text(lesson.homework)
                } else {
                    Text("无")
                        .foregroundColor(.secondary)
                }
            }

            if let studentName = lesson.studentName {
                Section("授课学生") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text(studentName)
                                .font(.headline)

                            if let student = studentVM.students.first(where: { $0.name == studentName }) {
                                if !student.grade.isEmpty {
                                    Text(student.grade)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()
                    }
                }
            }

            if !lesson.notes.isEmpty {
                Section("备注") {
                    Text(lesson.notes)
                }
            }

            Section {
                HStack {
                    Text("创建时间")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatDateTime(lesson.createdAt))
                        .font(.caption)
                }
            }
        }
        .navigationTitle("课程详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                LessonFormView(viewModel: lessonVM, studentVM: studentVM, lesson: lesson)
            }
        }
    }

    private var statusColor: Color {
        switch lesson.status {
        case .completed: return .green
        case .cancelled: return .red
        case .rescheduled: return .orange
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
