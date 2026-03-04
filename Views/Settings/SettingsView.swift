import SwiftUI

struct SettingsView: View {
    @ObservedObject var studentVM: StudentViewModel
    @StateObject private var syncService = SyncService.shared
    @State private var serverURL: String = APIService.shared.baseURL
    @State private var showingLogoutAlert = false
    @State private var showingSyncAlert = false
    @State private var syncMessage: String = ""
    @State private var isSyncing = false

    var body: some View {
        List {
                Section("数据导入导出") {
                    NavigationLink(destination: ImportView(studentVM: studentVM)) {
                        HStack {
                            Image(systemName: "doc.badge.arrow.up")
                                .foregroundColor(.blue)
                            Text("CSV 导入")
                        }
                    }

                    NavigationLink(destination: ExportView(studentVM: studentVM)) {
                        HStack {
                            Image(systemName: "doc.badge.arrow.down")
                                .foregroundColor(.green)
                            Text("导出数据")
                        }
                    }

                    NavigationLink(destination: WeakPointTagManageView()) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.orange)
                            Text("薄弱点标签管理")
                        }
                    }

                    NavigationLink(destination: WeakPointStatsView()) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundColor(.red)
                            Text("薄弱点统计")
                        }
                    }
                }

                Section("服务器设置") {
                    HStack {
                        Text("服务器地址")
                        Spacer()
                        TextField("http://localhost:8080", text: $serverURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 180)
                    }

                    Button {
                        saveServerURL()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("保存服务器地址")
                        }
                    }
                }

                Section("数据同步") {
                    Button {
                        performSync()
                    } label: {
                        HStack {
                            if isSyncing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            Text("立即同步")
                        }
                    }
                    .disabled(isSyncing)

                    if let lastSync = syncService.lastSyncDate {
                        HStack {
                            Text("上次同步")
                            Spacer()
                            Text(formatDate(lastSync))
                                .foregroundColor(.secondary)
                        }
                    }

                    Picker("同步模式", selection: $syncService.syncMode) {
                        Text("仅本地").tag(SyncMode.localOnly)
                        Text("仅远程").tag(SyncMode.remoteOnly)
                        Text("本地+远程").tag(SyncMode.both)
                    }
                }

                Section("账户") {
                    if APIService.shared.isLoggedIn {
                        Button(role: .destructive) {
                            showingLogoutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("退出登录")
                            }
                        }
                    } else {
                        NavigationLink(destination: LoginView()) {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("登录")
                            }
                        }
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink(destination: AboutView()) {
                        Text("关于应用")
                    }
                }
            }
            .navigationTitle("设置")
            .alert("退出登录", isPresented: $showingLogoutAlert) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    APIService.shared.logout()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
            .alert("同步结果", isPresented: $showingSyncAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(syncMessage)
            }
            .onAppear {
                serverURL = APIService.shared.baseURL
            }
        }

    private func saveServerURL() {
        APIService.shared.baseURL = serverURL
    }

    private func performSync() {
        isSyncing = true
        syncService.syncAll { success in
            isSyncing = false
            syncMessage = success ? "同步成功" : "同步失败: \(syncService.syncError ?? "未知错误")"
            showingSyncAlert = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("用户名", text: $username)
                    .autocapitalization(.none)
                SecureField("密码", text: $password)
            }

            Section {
                Button {
                    login()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                        }
                        Text("登录")
                    }
                }
                .disabled(username.isEmpty || password.isEmpty || isLoading)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("登录")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        APIService.shared.login(username: username, password: password) { result in
            isLoading = false
            switch result {
            case .success(let response):
                APIService.shared.authToken = response.token
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("学生课程管理系统")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("iOS 版")
                        .foregroundColor(.secondary)

                    Text("用于管理学生信息、课程记录和学习进度的移动应用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
        .navigationTitle("关于")
    }
}
