import SwiftUI

struct StudentDetailView: View {
    let student: Student
    @ObservedObject var studentVM: StudentViewModel
    @ObservedObject var lessonVM: LessonViewModel
    @ObservedObject var progressVM: ProgressViewModel
    @State private var selectedTab = 0

    var studentLessons: [Lesson] {
        guard let id = student.id else { return [] }
        return lessonVM.lessons.filter { $0.studentId == id }
    }

    var studentProgress: [ProgressRecord] {
        guard let id = student.id else { return [] }
        return progressVM.progressRecords.filter { $0.studentId == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Student Info Header
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text(student.name)
                    .font(.title)
                    .fontWeight(.bold)

                if !student.grade.isEmpty {
                    Text(student.grade)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

                HStack(spacing: 20) {
                    if !student.phone.isEmpty {
                        Label(student.phone, systemImage: "phone")
                    }
                    if !student.parentPhone.isEmpty {
                        Label(student.parentPhone, systemImage: "person.phone")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))

            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("课程 (\(studentLessons.count))").tag(0)
                Text("进度 (\(studentProgress.count))").tag(1)
                Text("详情").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Tab Content
            TabView(selection: $selectedTab) {
                // Lessons Tab
                if studentLessons.isEmpty {
                    emptyState(message: "暂无课程记录")
                } else {
                    List(studentLessons) { lesson in
                        LessonRowView(lesson: lesson)
                    }
                    .listStyle(.plain)
                }
                .tag(0)

                // Progress Tab
                if studentProgress.isEmpty {
                    emptyState(message: "暂无进度记录")
                } else {
                    List(studentProgress) { progress in
                        ProgressRowView(record: progress)
                    }
                    .listStyle(.plain)
                }
                .tag(1)

                // Details Tab
                List {
                    if !student.email.isEmpty {
                        DetailRow(icon: "envelope", title: "邮箱", value: student.email)
                    }
                    if !student.address.isEmpty {
                        DetailRow(icon: "location", title: "地址", value: student.address)
                    }
                    if !student.notes.isEmpty {
                        DetailRow(icon: "note.text", title: "备注", value: student.notes)
                    }

                    Section("统计") {
                        HStack {
                            Text("课程总数")
                            Spacer()
                            Text("\(studentLessons.count)")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("进度记录")
                            Spacer()
                            Text("\(studentProgress.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("学生详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lessonVM.loadLessons()
            progressVM.loadProgressRecords()
        }
    }

    private func emptyState(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
            }

            Spacer()
        }
    }
}
