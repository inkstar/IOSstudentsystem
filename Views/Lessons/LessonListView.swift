import SwiftUI

struct LessonListView: View {
    @ObservedObject var viewModel: LessonViewModel
    @ObservedObject var studentVM: StudentViewModel
    @State private var showingAddLesson = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Student Filter
                if !studentVM.students.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            StudentFilterButton(name: "全部", isSelected: viewModel.selectedStudentId == nil, action: {
                                viewModel.selectedStudentId = nil
                            })

                            ForEach(studentVM.students) { student in
                                StudentFilterButton(name: student.name, isSelected: viewModel.selectedStudentId == student.id, action: {
                                    viewModel.selectedStudentId = student.id
                                })
                            }
                        }
                        .padding()
                    }
                }

                // Lesson List
                if viewModel.filteredLessons.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "book")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无课程记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredLessons) { lesson in
                            NavigationLink(destination: LessonFormView(viewModel: viewModel, studentVM: studentVM, lesson: lesson)) {
                                LessonRowView(lesson: lesson)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteLesson(viewModel.filteredLessons[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("课程记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddLesson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLesson) {
                NavigationStack {
                    LessonFormView(viewModel: viewModel, studentVM: studentVM, lesson: nil)
                }
            }
            .onAppear {
                viewModel.loadLessons()
                studentVM.loadStudents()
            }
        }
    }
}

struct StudentFilterButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.subject)
                    .font(.headline)

                Spacer()

                statusBadge
            }

            HStack {
                Image(systemName: "person")
                    .foregroundColor(.secondary)
                Text(lesson.studentName ?? "未知学生")
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("\(lesson.lessonTime) | \(lesson.duration)分钟")
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formatDate(lesson.lessonDate))
                    .foregroundColor(.secondary)

                Spacer()

                if !lesson.homework.isEmpty {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }

    var statusBadge: some View {
        Text(lesson.status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }

    var statusColor: Color {
        switch lesson.status {
        case .completed: return .green
        case .cancelled: return .red
        case .rescheduled: return .orange
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
