import SwiftUI

struct WeakPointTagManageView: View {
    @StateObject private var viewModel = WeakPointViewModel()
    @State private var showingAddTag = false
    @State private var newTagName = ""
    @State private var newTagSubject = ""
    @State private var newTagIsGlobal = false

    private let subjects = ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"]

    var body: some View {
        List {
            Section {
                Button {
                    showingAddTag = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("添加新标签")
                    }
                }
            }

            Section("全局标签 (所有老师可见)") {
                let globalTags = viewModel.tags.filter { $0.isGlobal }
                if globalTags.isEmpty {
                    Text("暂无全局标签")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(globalTags) { tag in
                        TagRowView(tag: tag, onDelete: {
                            viewModel.deleteTag(tag)
                        })
                    }
                }
            }

            Section("个人标签 (仅自己可见)") {
                let personalTags = viewModel.tags.filter { !$0.isGlobal }
                if personalTags.isEmpty {
                    Text("暂无个人标签")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(personalTags) { tag in
                        TagRowView(tag: tag, onDelete: {
                            viewModel.deleteTag(tag)
                        })
                    }
                }
            }
        }
        .navigationTitle("标签管理")
        .sheet(isPresented: $showingAddTag) {
            NavigationStack {
                Form {
                    Section("标签信息") {
                        TextField("标签名称", text: $newTagName)

                        Picker("所属科目 (可选)", selection: $newTagSubject) {
                            Text("通用").tag("")
                            ForEach(subjects, id: \.self) { subject in
                                Text(subject).tag(subject)
                            }
                        }

                        Toggle("设为全局标签 (所有老师可见)", isOn: $newTagIsGlobal)
                    }
                }
                .navigationTitle("添加标签")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showingAddTag = false
                            newTagName = ""
                            newTagSubject = ""
                            newTagIsGlobal = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let tag = WeakPointTag(
                                name: newTagName,
                                subject: newTagSubject.isEmpty ? nil : newTagSubject,
                                isGlobal: newTagIsGlobal
                            )
                            viewModel.saveTag(tag)
                            showingAddTag = false
                            newTagName = ""
                            newTagSubject = ""
                            newTagIsGlobal = false
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadTags()
        }
    }
}

struct TagRowView: View {
    let tag: WeakPointTag
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tag.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    if let subject = tag.subject, !subject.isEmpty {
                        Text(subject)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }

                    if tag.isGlobal {
                        Text("全局")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
