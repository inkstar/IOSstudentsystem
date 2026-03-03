import SwiftUI

struct WeakPointsByGradeView: View {
    @StateObject private var viewModel = KnowledgePointViewModel()
    @ObservedObject var studentVM: StudentViewModel
    @State private var selectedGrade: String = ""

    var grades: [String] {
        let allGrades = Set(studentVM.students.map { $0.grade })
        return Array(allGrades).sorted()
    }

    var filteredPoints: [KnowledgePoint] {
        if selectedGrade.isEmpty {
            return viewModel.gradeWeakPoints
        }
        return viewModel.gradeWeakPoints.filter { $0.grade == selectedGrade }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Grade Filter
            if !grades.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button("全部") {
                            selectedGrade = ""
                            viewModel.loadGradeWeakPoints(forGrade: "")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(selectedGrade.isEmpty ? .white : .blue)
                        .background(selectedGrade.isEmpty ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(8)

                        ForEach(grades, id: \.self) { grade in
                            Button(grade) {
                                selectedGrade = grade
                                viewModel.loadGradeWeakPoints(forGrade: grade)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(selectedGrade == grade ? .white : .blue)
                            .background(selectedGrade == grade ? Color.blue : Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))
            }

            // Sort Controls
            HStack {
                Text("共 \(filteredPoints.count) 个薄弱知识点")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(viewModel.sortByCount ? "按次数排序" : "按分数排序") {
                    viewModel.toggleSortOrder()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
            .padding()

            // Content
            if filteredPoints.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("暂无薄弱知识点")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredPoints) { point in
                    GradeWeakPointRowView(point: point)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("年级薄弱知识点")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            studentVM.loadStudents()
            viewModel.loadGradeWeakPoints(forGrade: selectedGrade)
        }
    }
}

struct GradeWeakPointRowView: View {
    let point: KnowledgePoint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)

                Text(point.topic)
                    .font(.headline)

                Spacer()

                Text(point.subject)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }

            HStack {
                if let studentName = point.studentName {
                    Label(studentName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !point.grade.isEmpty {
                    Text(point.grade)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Label("\(point.recordCount)次", systemImage: "number")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("累计: \(Int(point.totalScore))分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
