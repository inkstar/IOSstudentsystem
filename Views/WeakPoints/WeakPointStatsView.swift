import SwiftUI
import Charts

struct WeakPointStatsView: View {
    @StateObject private var viewModel = WeakPointViewModel()
    @StateObject private var studentVM = StudentViewModel()
    @State private var selectedClassName: String = ""
    @State private var selectedStudentId: Int64?

    var body: some View {
        List {
            Section("统计维度") {
                Picker("统计维度", selection: $selectedClassName) {
                    Text("按学生").tag("")
                    if !studentVM.classNames.isEmpty {
                        ForEach(studentVM.classNames, id: \.self) { className in
                            Text("班级: \(className)").tag(className)
                        }
                    }
                }
            }

            if selectedClassName.isEmpty {
                // Student-level stats
                Section("选择学生") {
                    Picker("选择学生", selection: $selectedStudentId) {
                        Text("请选择学生").tag(Int64?.none)
                        ForEach(studentVM.activeStudents) { student in
                            Text(student.name).tag(student.id as Int64?)
                        }
                    }
                }

                if let studentId = selectedStudentId {
                    let stats = viewModel.getWeakPointStats(forStudentId: studentId)
                    let frequency = viewModel.getWeakPointsGroupedByFrequency(forStudentId: studentId)

                    Section("薄弱点统计") {
                        LabeledContent("薄弱点总数", value: "\(stats.total)")
                        LabeledContent("涉及知识点", value: "\(stats.topics.count)")
                    }

                    if !frequency.isEmpty {
                        Section("高频薄弱点") {
                            Chart(frequency.prefix(10), id: \.topic) { item in
                                BarMark(
                                    x: .value("频次", item.count),
                                    y: .value("知识点", item.topic)
                                )
                                .foregroundStyle(Color.red.gradient)
                            }
                            .frame(height: 200)
                        }

                        Section("薄弱点列表") {
                            ForEach(frequency, id: \.topic) { item in
                                HStack {
                                    Text(item.topic)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("出现 \(item.count) 次")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                // Class-level stats
                let classStats = viewModel.getClassWeakPointStats(className: selectedClassName)
                let classFrequency = viewModel.getWeakPointsGroupedByFrequency(forClassName: selectedClassName)

                Section("班级统计") {
                    LabeledContent("班级人数", value: "\(studentVM.getStudentsByClassName(selectedClassName).count)")
                    LabeledContent("有薄弱点学生", value: "\(classStats.studentCount)")
                    LabeledContent("薄弱点总数", value: "\(classStats.totalWeakPoints)")
                    LabeledContent("涉及知识点", value: "\(classStats.uniqueTopics)")
                }

                if !classFrequency.isEmpty {
                    Section("班级高频薄弱点") {
                        Chart(classFrequency.prefix(10), id: \.topic) { item in
                            BarMark(
                                x: .value("出现次数", item.count),
                                y: .value("知识点", item.topic)
                            )
                            .foregroundStyle(Color.orange.gradient)
                        }
                        .frame(height: 200)
                    }

                    Section("薄弱点详情") {
                        ForEach(classFrequency, id: \.topic) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.topic)
                                        .font(.subheadline)
                                    Text("涉及 \(item.studentCount) 名学生")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("共 \(item.count) 次")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("薄弱点统计")
        .onAppear {
            viewModel.loadKnowledgePoints()
            studentVM.loadStudents()
        }
    }
}
