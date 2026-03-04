import SwiftUI

struct ExamScoreView: View {
    let exam: Exam
    @ObservedObject var viewModel: ExamViewModel
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var scores: [ExamScore] = []

    var body: some View {
        List {
            Section("考试信息") {
                Text(exam.name)
                Text("科目: \(exam.subject)")
                Text("总分: \(Int(exam.totalScore))")
            }

            Section("成绩录入") {
                ForEach($scores) { $score in
                    ScoreInputRow(score: $score)
                }
            }
        }
        .navigationTitle("录入成绩")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveScores()
                }
            }
        }
        .onAppear {
            loadStudents()
        }
    }

    private func loadStudents() {
        let students: [Student]
        if let className = exam.className, !className.isEmpty {
            students = studentVM.getStudentsByClassName(className)
        } else {
            students = studentVM.activeStudents
        }

        let existingScores = DatabaseService.shared.getExamScores(forExamId: exam.id ?? 0)

        scores = students.map { student in
            if let existing = existingScores.first(where: { $0.studentId == student.id }) {
                return existing
            }
            return ExamScore(
                examId: exam.id ?? 0,
                studentId: student.id ?? 0,
                studentName: student.name,
                scores: [exam.subject: 0]
            )
        }
    }

    private func saveScores() {
        // Calculate total scores
        for i in scores.indices {
            scores[i].totalScore = scores[i].scores.values.reduce(0, +)
        }

        // Update ranks
        let sorted = scores.sorted { $0.totalScore > $1.totalScore }
        for (index, score) in sorted.enumerated() {
            if let i = scores.firstIndex(where: { $0.id == score.id }) {
                scores[i].rank = index + 1
            }
        }

        viewModel.saveScoreBatch(scores)
        dismiss()
    }
}

struct ScoreInputRow: View {
    @Binding var score: ExamScore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(score.studentName)
                .font(.headline)

            HStack {
                Text("分数:")
                TextField("0", value: Binding(
                    get: { score.scores.values.first ?? 0 },
                    set: { newValue in
                        score.scores[Array(score.scores.keys)[0]] = newValue
                    }
                ), format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 80)
                Text("/ \(Int(score.totalScore))")
                    .foregroundColor(.secondary)

                Spacer()

                if let rank = score.rank {
                    Text("第\(rank)名")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gold.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }

            TextField("评语 (可选)", text: Binding(
                get: { score.comment ?? "" },
                set: { score.comment = $0.isEmpty ? nil : $0 }
            ))
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
