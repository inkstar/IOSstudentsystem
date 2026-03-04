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
            } else if syncService.lastSyncDate != nil {
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

struct KnowledgePointRowView: View {
    let point: KnowledgePoint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: point.type.icon)
                    .foregroundColor(point.type == .mastered ? .green : .orange)

                Text(point.topic)
                    .font(.headline)

                Spacer()

                Text(point.subject)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }

            HStack(spacing: 16) {
                Label("\(point.recordCount)次记录", systemImage: "number")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label("累计分数: \(Int(point.totalScore))", systemImage: "sum")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let lastDate = Optional(point.lastRecordDate) {
                    Text("最近: \(lastDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
