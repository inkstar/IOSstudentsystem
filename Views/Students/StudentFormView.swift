import SwiftUI

struct StudentFormView: View {
    @ObservedObject var viewModel: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    let student: Student?
    @State private var name: String = ""
    @State private var grade: String = ""
    @State private var phone: String = ""
    @State private var parentPhone: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var notes: String = ""

    private let grades = ["一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "初二", "初三", "高一", "高二", "高三"]

    var isEditing: Bool {
        student != nil
    }

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("姓名", text: $name)

                Picker("年级", selection: $grade) {
                    Text("请选择年级").tag("")
                    ForEach(grades, id: \.self) { g in
                        Text(g).tag(g)
                    }
                }

                TextField("联系电话", text: $phone)
                    .keyboardType(.phonePad)

                TextField("家长电话", text: $parentPhone)
                    .keyboardType(.phonePad)
            }

            Section("其他信息") {
                TextField("邮箱", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                TextField("地址", text: $address)

                TextField("备注", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(isEditing ? "编辑学生" : "添加学生")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveStudent()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let student = student {
                name = student.name
                grade = student.grade
                phone = student.phone
                parentPhone = student.parentPhone
                email = student.email
                address = student.address
                notes = student.notes
            }
        }
    }

    private func saveStudent() {
        var newStudent = student ?? Student()
        newStudent.name = name
        newStudent.grade = grade
        newStudent.phone = phone
        newStudent.parentPhone = parentPhone
        newStudent.email = email
        newStudent.address = address
        newStudent.notes = notes

        viewModel.saveStudent(newStudent)
        dismiss()
    }
}
