import SwiftUI

struct ExamListView: View {
    @StateObject private var viewModel = ExamViewModel()
    @State private var showingAddExam = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                VStack(spacing: 12) {
                    // Class Name Filter
                    if !viewModel.classNames.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "全部班级", isSelected: viewModel.selectedClassName == "", action: {
                                    viewModel.selectedClassName = ""
                                })

                                ForEach(viewModel.classNames, id: \.self) { className in
                                    FilterChip(title: className, isSelected: viewModel.selectedClassName == className, action: {
                                        viewModel.selectedClassName = className
                                    })
                                }
                            }
                        }
                    }

                    // Subject Filter
                    if !viewModel.subjects.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "全部科目", isSelected: viewModel.selectedSubject == "", action: {
                                    viewModel.selectedSubject = ""
                                })

                                ForEach(viewModel.subjects, id: \.self) { subject in
                                    FilterChip(title: subject, isSelected: viewModel.selectedSubject == subject, action: {
                                        viewModel.selectedSubject = subject
                                    })
                                }
                            }
                        }
                    }
                }
                .padding()

                // Exam List
                if viewModel.filteredExams.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无考试记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredExams) { exam in
                            NavigationLink(destination: ExamDetailView(exam: exam, viewModel: viewModel)) {
                                ExamRowView(exam: exam)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteExam(viewModel.filteredExams[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("考试成绩")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExam = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExam) {
                NavigationStack {
                    ExamFormView(viewModel: viewModel, exam: nil)
                }
            }
            .onAppear {
                viewModel.loadExams()
            }
        }
    }
}

struct ExamRowView: View {
    let exam: Exam

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exam.name)
                    .font(.headline)
                Spacer()
                Text(formatDate(exam.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(exam.subject)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(4)

                if let className = exam.className, !className.isEmpty {
                    Text(className)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }

                Spacer()

                Text("总分: \(Int(exam.totalScore))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ExamDetailView: View {
    let exam: Exam
    @ObservedObject var viewModel: ExamViewModel
    @State private var showingScoreSheet = false
    @StateObject private var studentVM = StudentViewModel()

    var body: some View {
        List {
            Section("考试信息") {
                LabeledContent("考试名称", value: exam.name)
                LabeledContent("考试日期", value: formatDate(exam.date))
                LabeledContent("科目", value: exam.subject)
                LabeledContent("总分", value: "\(Int(exam.totalScore))")
                if let className = exam.className, !className.isEmpty {
                    LabeledContent("班级", value: className)
                }
                if let notes = exam.notes, !notes.isEmpty {
                    LabeledContent("备注", value: notes)
                }
            }

            Section {
                Button {
                    showingScoreSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("录入成绩")
                    }
                }
            }

            Section("成绩记录") {
                if viewModel.examScores.isEmpty {
                    Text("暂无成绩记录")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.examScores.sorted { ($0.rank ?? 999) < ($1.rank ?? 999) }) { score in
                        ExamScoreRowView(score: score)
                    }
                }
            }
        }
        .navigationTitle("考试详情")
        .sheet(isPresented: $showingScoreSheet) {
            NavigationStack {
                ExamScoreView(exam: exam, viewModel: viewModel, studentVM: studentVM)
            }
        }
        .onAppear {
            viewModel.loadScores(forExamId: exam.id ?? 0)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

struct ExamScoreRowView: View {
    let score: ExamScore

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(score.studentName)
                        .font(.headline)
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

                Text("总分: \(String(format: "%.1f", score.totalScore))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}
