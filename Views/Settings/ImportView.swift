import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @ObservedObject var studentVM: StudentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var importResult: ImportResult?
    @State private var isImporting = false
    @State private var csvContent = ""

    var body: some View {
        Form {
            Section("CSV 导入说明") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV 文件格式要求:")
                        .font(.headline)
                    Text("姓名,性别,年级,学校,电话,家长电话,班级")
                        .font(.caption)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
            }

            Section("导入操作") {
                Button {
                    isImporting = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.arrow.up")
                        Text("选择 CSV 文件")
                    }
                }

                if let result = importResult {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("导入成功:")
                            Text("\(result.successCount) 条")
                                .foregroundColor(.green)
                        }
                        if result.errorCount > 0 {
                            HStack {
                                Text("导入失败:")
                                Text("\(result.errorCount) 条")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.top, 8)

                    if !result.errors.isEmpty {
                        Section("错误详情") {
                            ForEach(result.errors, id: \.row) { error in
                                VStack(alignment: .leading) {
                                    Text("第 \(error.row) 行")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text(error.message)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }

            Section("模板下载") {
                Button {
                    exportTemplate()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("下载导入模板")
                    }
                }
            }
        }
        .navigationTitle("CSV 导入")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .onAppear {
            studentVM.loadStudents()
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }

                let content = try String(contentsOf: url, encoding: .utf8)
                importResult = ImportService.shared.importStudentsFromCSV(content)
                studentVM.loadStudents()
            } catch {
                importResult = ImportResult(successCount: 0, errorCount: 1, errors: [(row: 0, message: "读取文件失败: \(error.localizedDescription)")])
            }

        case .failure(let error):
            importResult = ImportResult(successCount: 0, errorCount: 1, errors: [(row: 0, message: "选择文件失败: \(error.localizedDescription)")])
        }
    }

    private func exportTemplate() {
        let template = ImportService.shared.generateStudentCSVTemplate()
        // This would typically trigger a share sheet
    }
}
