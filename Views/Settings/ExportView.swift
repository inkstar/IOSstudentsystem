import SwiftUI

struct ExportView: View {
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStudentId: Int64?
    @State private var isGenerating = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        Form {
            Section("PDF 导出") {
                Picker("选择学生", selection: $selectedStudentId) {
                    Text("请选择学生").tag(Int64?.none)
                    ForEach(studentVM.activeStudents) { student in
                        Text(student.name).tag(student.id as Int64?)
                    }
                }
            }

            Section {
                Button {
                    generatePDF()
                } label: {
                    HStack {
                        Image(systemName: "doc.richtext")
                        Text("生成 PDF 报告")
                    }
                }
                .disabled(selectedStudentId == nil || isGenerating)

                if isGenerating {
                    ProgressView("正在生成...")
                }
            }

            Section("报告内容") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 学生基本信息")
                    Text("• 近期课程记录")
                    Text("• 考试成绩趋势")
                    Text("• 薄弱点汇总")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Section("其他导出") {
                Button {
                    exportCSV()
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("导出学生 CSV")
                    }
                }

                Button {
                    exportJSON()
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.arrow.up")
                        Text("导出 JSON")
                    }
                }
            }
        }
        .navigationTitle("数据导出")
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .onAppear {
            studentVM.loadStudents()
        }
    }

    private func generatePDF() {
        guard let studentId = selectedStudentId,
              let student = studentVM.students.first(where: { $0.id == studentId }) else {
            return
        }

        isGenerating = true

        if let pdfData = PDFExportService.shared.generateStudentReport(student: student) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(student.name)_学习报告.pdf")
            do {
                try pdfData.write(to: tempURL)
                shareItems = [tempURL]
                showShareSheet = true
            } catch {
                print("Error saving PDF: \(error)")
            }
        }

        isGenerating = false
    }

    private func exportCSV() {
        let csv = ImportService.shared.exportStudentsToCSV(studentVM.activeStudents)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("students.csv")
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            shareItems = [tempURL]
            showShareSheet = true
        } catch {
            print("Error saving CSV: \(error)")
        }
    }

    private func exportJSON() {
        let json = ExportService.shared.exportStudentsToJSON() ?? "{}"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("students.json")
        do {
            try json.write(to: tempURL, atomically: true, encoding: .utf8)
            shareItems = [tempURL]
            showShareSheet = true
        } catch {
            print("Error saving JSON: \(error)")
        }
    }
}
