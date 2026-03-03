import SwiftUI

struct ProgressListView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @ObservedObject var studentVM: StudentViewModel
    @State private var showingAddProgress = false

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

                // Progress List
                if viewModel.filteredProgressRecords.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无进度记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredProgressRecords) { record in
                            NavigationLink(destination: ProgressFormView(viewModel: viewModel, studentVM: studentVM, progressRecord: record)) {
                                ProgressRowView(record: record)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteProgressRecord(viewModel.filteredProgressRecords[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("学习进度")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddProgress = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProgress) {
                NavigationStack {
                    ProgressFormView(viewModel: viewModel, studentVM: studentVM, progressRecord: nil)
                }
            }
            .onAppear {
                viewModel.loadProgressRecords()
                studentVM.loadStudents()
            }
        }
    }
}

struct ProgressRowView: View {
    let record: ProgressRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.subject)
                    .font(.headline)

                Spacer()

                masteryBadge
            }

            HStack {
                Image(systemName: "person")
                    .foregroundColor(.secondary)
                Text(record.studentName ?? "未知学生")
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "bookmark")
                    .foregroundColor(.secondary)
                Text(record.topic)
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formatDate(record.recordDate))
                    .foregroundColor(.secondary)

                Spacer()

                if record.score > 0 {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f分", record.score))
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }

    var masteryBadge: some View {
        Text(record.masteryLevel.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(masteryColor.opacity(0.2))
            .foregroundColor(masteryColor)
            .cornerRadius(4)
    }

    var masteryColor: Color {
        switch record.masteryLevel {
        case .excellent: return .green
        case .good: return .blue
        case .average: return .orange
        case .poor: return .red
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
