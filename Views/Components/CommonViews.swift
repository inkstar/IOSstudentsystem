import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct LoadingView: View {
    var message: String = "加载中..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("出错了")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let action = retryAction {
                Button(action: action) {
                    Text("重试")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

struct SyncStatusBadge: View {
    @ObservedObject var syncService = SyncService.shared

    var body: some View {
        HStack(spacing: 4) {
            if syncService.isSyncing {
                ProgressView()
                    .scaleEffect(0.6)
                Text("同步中...")
                    .font(.caption)
            } else if let lastSync = syncService.lastSyncDate {
                Image(systemName: "checkmark.icloud")
                    .foregroundColor(.green)
                Text("已同步")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "icloud.slash")
                    .foregroundColor(.secondary)
                Text("未同步")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
