import SwiftUI

struct ClassSessionListView: View {
    @StateObject private var viewModel = ClassSessionViewModel()
    @StateObject private var studentVM = StudentViewModel()
    @State private var showingAddSession = false

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

                // Session List
                if viewModel.filteredSessions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无课堂记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredSessions) { session in
                            NavigationLink(destination: ClassSessionDetailView(session: session, viewModel: viewModel, studentVM: studentVM)) {
                                ClassSessionRowView(session: session)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteSession(viewModel.filteredSessions[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("课堂记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSession = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSession) {
                NavigationStack {
                    ClassSessionFormView(viewModel: viewModel, session: nil)
                }
            }
            .onAppear {
                viewModel.loadSessions()
                studentVM.loadStudents()
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct ClassSessionRowView: View {
    let session: ClassSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.className)
                    .font(.headline)
                Spacer()
                Text(formatDate(session.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(session.subject)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(4)

                if let topic = session.topic, !topic.isEmpty {
                    Text(topic)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(session.startTime) - \(session.endTime)")
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

struct ClassSessionDetailView: View {
    let session: ClassSession
    @ObservedObject var viewModel: ClassSessionViewModel
    @ObservedObject var studentVM: StudentViewModel
    @State private var showingAttendanceSheet = false

    var body: some View {
        List {
            Section("课堂信息") {
                LabeledContent("班级", value: session.className)
                LabeledContent("日期", value: formatDate(session.date))
                LabeledContent("时间", value: "\(session.startTime) - \(session.endTime)")
                LabeledContent("科目", value: session.subject)
                if let topic = session.topic, !topic.isEmpty {
                    LabeledContent("主题", value: topic)
                }
                if let notes = session.notes, !notes.isEmpty {
                    LabeledContent("备注", value: notes)
                }
            }

            Section {
                Button {
                    showingAttendanceSheet = true
                } label: {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("登记出勤")
                    }
                }
            }
        }
        .navigationTitle("课堂详情")
        .sheet(isPresented: $showingAttendanceSheet) {
            NavigationStack {
                AttendanceBatchView(session: session, viewModel: viewModel, studentVM: studentVM)
            }
        }
        .onAppear {
            viewModel.loadAttendance(forSessionId: session.id ?? 0)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
