import SwiftUI

struct AttendanceBatchView: View {
    let session: ClassSession
    @ObservedObject var viewModel: ClassSessionViewModel
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var attendanceRecords: [Attendance] = []
    @State private var isSaving = false

    var body: some View {
        List {
            Section {
                Text("班级: \(session.className)")
                Text("科目: \(session.subject)")
                Text("日期: \(formatDate(session.date))")
            }

            Section("学生出勤登记") {
                ForEach($attendanceRecords) { $record in
                    AttendanceRowView(record: $record)
                }
            }
        }
        .navigationTitle("登记出勤")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveAttendance()
                }
                .disabled(isSaving)
            }
        }
        .onAppear {
            loadStudents()
        }
    }

    private func loadStudents() {
        let students = studentVM.getStudentsByClassName(session.className)
        let existingAttendance = DatabaseService.shared.getAttendance(forSessionId: session.id ?? 0)

        attendanceRecords = students.map { student in
            // Check if attendance already exists
            if let existing = existingAttendance.first(where: { $0.studentId == student.id }) {
                return existing
            }
            // Create new attendance record
            return Attendance(
                sessionId: session.id ?? 0,
                studentId: student.id ?? 0,
                studentName: student.name,
                status: .present
            )
        }
    }

    private func saveAttendance() {
        isSaving = true
        viewModel.saveAttendanceBatch(attendanceRecords)
        isSaving = false
        dismiss()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AttendanceRowView: View {
    @Binding var record: Attendance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.studentName)
                .font(.headline)

            HStack {
                Picker("出勤状态", selection: $record.status) {
                    ForEach(AttendanceStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.menu)

                if record.status == .present {
                    Picker("课堂表现", selection: $record.performance) {
                        Text("请选择").tag(PerformanceLevel?.none)
                        ForEach(PerformanceLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(PerformanceLevel?.some(level))
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            if record.status == .present {
                TextField("作业完成情况", text: Binding(
                    get: { record.homework ?? "" },
                    set: { record.homework = $0.isEmpty ? nil : $0 }
                ))
                .font(.caption)

                TextField("老师评语", text: Binding(
                    get: { record.comment ?? "" },
                    set: { record.comment = $0.isEmpty ? nil : $0 }
                ))
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
