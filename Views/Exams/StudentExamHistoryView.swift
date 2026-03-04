import SwiftUI
import Charts

struct StudentExamHistoryView: View {
    let student: Student
    @ObservedObject var viewModel: ExamViewModel
    @Environment(\.dismiss) private var dismiss

    var examHistory: [(exam: Exam, score: ExamScore)] {
        viewModel.getStudentExamHistory(studentId: student.id ?? 0)
    }

    var body: some View {
        List {
            studentInfoSection
            trendSection
            historySection
            statsSection
        }
        .navigationTitle("成绩趋势")
        .onAppear {
            viewModel.loadExams()
            viewModel.loadScores(forStudentId: student.id ?? 0)
        }
    }

    private var studentInfoSection: some View {
        Section("学生信息") {
            Text("姓名: \(student.name)")
            Text("年级: \(student.grade)")
            if let className = student.className {
                Text("班级: \(className)")
            }
        }
    }

    private var trendSection: some View {
        Section("成绩趋势") {
            if examHistory.isEmpty {
                Text("暂无考试记录")
                    .foregroundColor(.secondary)
            } else {
                Chart(examHistory, id: \.exam.id) { item in
                    LineMark(
                        x: .value("考试", item.exam.name),
                        y: .value("总分", item.score.totalScore)
                    )
                    .foregroundStyle(.blue)
                    .symbol(.circle)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...chartUpperBound)
            }
        }
    }

    private var chartUpperBound: Double {
        (examHistory.map { $0.score.totalScore }.max() ?? 100) + 20
    }

    private var historySection: some View {
        Section("历史成绩") {
            if examHistory.isEmpty {
                Text("暂无考试记录")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(examHistory.reversed()), id: \.exam.id) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.exam.name)
                                .font(.headline)
                            Spacer()
                            Text(formatDate(item.exam.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text(item.exam.subject)
                                .font(.subheadline)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(4)

                            Spacer()

                            Text("总分: \(String(format: "%.1f", item.score.totalScore))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let rank = item.score.rank {
                                Text("第\(rank)名")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gold.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(4)
                            }
                        }

                        if let comment = item.score.comment, !comment.isEmpty {
                            Text(comment)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var statsSection: some View {
        Section("成绩统计") {
            if !examHistory.isEmpty {
                let totalExams = examHistory.count
                let avgScore = examHistory.map { $0.score.totalScore }.reduce(0, +) / Double(totalExams)
                let maxScore = examHistory.map { $0.score.totalScore }.max() ?? 0
                let minScore = examHistory.map { $0.score.totalScore }.min() ?? 0
                let ranks = examHistory.compactMap { $0.score.rank }
                let avgRank = ranks.isEmpty ? 0 : ranks.reduce(0, +) / ranks.count

                LabeledContent("考试次数", value: "\(totalExams)")
                LabeledContent("平均分", value: String(format: "%.1f", avgScore))
                LabeledContent("最高分", value: String(format: "%.1f", maxScore))
                LabeledContent("最低分", value: String(format: "%.1f", minScore))
                LabeledContent("平均排名", value: "\(avgRank)")
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
