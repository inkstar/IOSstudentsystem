import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var studentVM = StudentViewModel()
    @StateObject private var lessonVM = LessonViewModel()
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 学生年级分布
                    if !studentVM.students.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("学生年级分布")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(studentGradeDistribution) { item in
                                BarMark(
                                    x: .value("年级", item.grade),
                                    y: .value("人数", item.count)
                                )
                                .foregroundStyle(Color.blue.gradient)
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }

                    // 课程状态分布
                    if !lessonVM.lessons.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("课程状态分布")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(lessonStatusDistribution) { item in
                                BarMark(
                                    x: .value("状态", item.status),
                                    y: .value("数量", item.count)
                                )
                                .foregroundStyle(by: .value("状态", item.status))
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }

                    // 每周课程趋势
                    if !weeklyLessonData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("本周课程趋势")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(weeklyLessonData) { item in
                                LineMark(
                                    x: .value("日期", item.date),
                                    y: .value("课程数", item.count)
                                )
                                .foregroundStyle(Color.blue)
                                .symbol(Circle())

                                PointMark(
                                    x: .value("日期", item.date),
                                    y: .value("课程数", item.count)
                                )
                                .foregroundStyle(Color.blue)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }

                    // 掌握程度分布
                    if !progressVM.progressRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("掌握程度分布")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(masteryDistribution) { item in
                                BarMark(
                                    x: .value("程度", item.level),
                                    y: .value("人数", item.count)
                                )
                                .foregroundStyle(by: .value("程度", item.level))
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }

                    // 科目分布
                    if !subjectDistribution.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("课程科目分布")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(subjectDistribution) { item in
                                BarMark(
                                    x: .value("科目", item.subject),
                                    y: .value("数量", item.count)
                                )
                                .foregroundStyle(Color.green.gradient)
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("数据统计")
            .onAppear {
                studentVM.loadStudents()
                lessonVM.loadLessons()
                progressVM.loadProgressRecords()
            }
        }
    }

    // MARK: - Data

    private var studentGradeDistribution: [GradeCount] {
        let grouped = Dictionary(grouping: studentVM.students) { $0.grade }
        return grouped.map { GradeCount(grade: $0.key.isEmpty ? "未知" : $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var lessonStatusDistribution: [StatusCount] {
        let grouped = Dictionary(grouping: lessonVM.lessons) { $0.status.displayName }
        return grouped.map { StatusCount(status: $0.key, count: $0.value.count) }
    }

    private var weeklyLessonData: [DayLessonCount] {
        let calendar = Calendar.current
        let today = Date()
        var data: [DayLessonCount] = []

        for dayOffset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let count = lessonVM.lessons.filter { lesson in
                    calendar.isDate(lesson.lessonDate, inSameDayAs: date)
                }.count
                data.append(DayLessonCount(date: date, count: count))
            }
        }

        return data
    }

    private var masteryDistribution: [MasteryCount] {
        let grouped = Dictionary(grouping: progressVM.progressRecords) { $0.masteryLevel.displayName }
        return grouped.map { MasteryCount(level: $0.key, count: $0.value.count) }
    }

    private var subjectDistribution: [SubjectCount] {
        let grouped = Dictionary(grouping: lessonVM.lessons) { $0.subject }
        return grouped.map { SubjectCount(subject: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5).map { $0 }
    }
}

// MARK: - Data Models

struct GradeCount: Identifiable {
    let id = UUID()
    let grade: String
    let count: Int
}

struct StatusCount: Identifiable {
    let id = UUID()
    let status: String
    let count: Int
}

struct DayLessonCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct MasteryCount: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
}

struct SubjectCount: Identifiable {
    let id = UUID()
    let subject: String
    let count: Int
}

#Preview {
    StatisticsView()
}
