import SwiftUI

struct StudentListView: View {
    @ObservedObject var viewModel: StudentViewModel
    @State private var showingAddStudent = false

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
                            NavigationLink(destination: StudentFormView(viewModel: viewModel, student: student)) {
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
                    Button {
                        showingAddStudent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStudent) {
                NavigationStack {
                    StudentFormView(viewModel: viewModel, student: nil)
                }
            }
            .onAppear {
                viewModel.loadStudents()
            }
        }
    }
}

struct GradeFilterButton: View {
    let grade: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(grade.isEmpty ? "全部" : grade)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
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
                Text(student.name)
                    .font(.headline)
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
                    if !student.phone.isEmpty {
                        Text(student.phone)
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
