import SwiftUI

struct StudentListView: View {
    @ObservedObject var viewModel: StudentViewModel
    @StateObject private var lessonVM = LessonViewModel()
    @StateObject private var progressVM = ProgressViewModel()
    @State private var showingAddStudent = false
    @State private var showingExportSheet = false
    @State private var exportContent: String = ""
    @State private var exportFileName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("搜索学生姓名", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Grade Filter
                    if !viewModel.grades.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                GradeFilterButton(grade: "", isSelected: viewModel.selectedGrade == "", action: {
                                    viewModel.selectedGrade = ""
                                })

                                ForEach(viewModel.grades, id: \.self) { grade in
                                    GradeFilterButton(grade: grade, isSelected: viewModel.selectedGrade == grade, action: {
                                        viewModel.selectedGrade = grade
                                    })
                                }
                            }
                        }
                    }

                    // Class Name Filter
                    if !viewModel.classNames.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ClassFilterButton(className: "", isSelected: viewModel.selectedClassName == "", action: {
                                    viewModel.selectedClassName = ""
                                })

                                ForEach(viewModel.classNames, id: \.self) { className in
                                    ClassFilterButton(className: className, isSelected: viewModel.selectedClassName == className, action: {
                                        viewModel.selectedClassName = className
                                    })
                                }
                            }
                        }
                    }

                    // Show Archived Toggle
                    Toggle("显示已归档学生", isOn: $viewModel.showArchived)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                .padding()

                // Student List
                if viewModel.filteredStudents.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无学生")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredStudents) { student in
                            NavigationLink(destination: StudentDetailView(student: student, studentVM: viewModel, lessonVM: lessonVM, progressVM: progressVM)) {
                                StudentRowView(student: student)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteStudent(viewModel.filteredStudents[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("学生管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddStudent = true
                        } label: {
                            Label("添加学生", systemImage: "plus")
                        }

                        Divider()

                        Button {
                            exportData(format: "csv")
                        } label: {
                            Label("导出 CSV", systemImage: "doc.text")
                        }

                        Button {
                            exportData(format: "json")
                        } label: {
                            Label("导出 JSON", systemImage: "doc.badge.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddStudent) {
                NavigationStack {
                    StudentFormView(viewModel: viewModel, student: nil)
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [exportContent])
            }
            .onAppear {
                viewModel.loadStudents()
            }
        }
    }

    private func exportData(format: String) {
        if format == "csv" {
            exportContent = ExportService.shared.exportStudentsToCSV()
            exportFileName = "students.csv"
        } else {
            exportContent = ExportService.shared.exportStudentsToJSON() ?? "{}"
            exportFileName = "students.json"
        }
        showingExportSheet = true
    }
}

struct GradeFilterButton: View {
    let grade: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(grade.isEmpty ? "全部年级" : grade)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct ClassFilterButton: View {
    let className: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(className.isEmpty ? "全部分班" : className)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct StudentRowView: View {
    let student: Student

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(student.name)
                        .font(.headline)
                    if student.archived {
                        Text("已归档")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                    }
                }
                HStack(spacing: 8) {
                    if !student.grade.isEmpty {
                        Text(student.grade)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    if let className = student.className, !className.isEmpty {
                        Text(className)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                    if !student.gender.isEmpty {
                        Text(student.gender)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
