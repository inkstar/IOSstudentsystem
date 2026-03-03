import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var lessonVM: LessonViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCardView(title: "学生总数", value: "\(viewModel.studentCount)", icon: "person.3.fill", color: .blue)
                        StatCardView(title: "课程总数", value: "\(viewModel.lessonCount)", icon: "book.fill", color: .green)
                        StatCardView(title: "本周课程", value: "\(viewModel.weekLessonCount)", icon: "calendar", color: .orange)
                        StatCardView(title: "出勤率", value: String(format: "%.0f%%", viewModel.attendanceRate), icon: "checkmark.circle.fill", color: .purple)
                    }
                    .padding(.horizontal)

                    // Recent Lessons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("近期课程")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.recentLessons.isEmpty {
                            Text("暂无课程记录")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(viewModel.recentLessons) { lesson in
                                RecentLessonRow(lesson: lesson)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("仪表盘")
            .onAppear {
                viewModel.loadData()
                lessonVM.loadLessons()
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecentLessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.subject)
                    .font(.headline)
                Text(lesson.studentName ?? "未知学生")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(lesson.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)

                Text(formatDate(lesson.lessonDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
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
