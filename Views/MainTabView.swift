import SwiftUI

struct MainTabView: View {
    @StateObject private var studentVM = StudentViewModel()
    @StateObject private var lessonVM = LessonViewModel()
    @StateObject private var progressVM = ProgressViewModel()
    @StateObject private var dashboardVM = DashboardViewModel()

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardVM, lessonVM: lessonVM)
                .tabItem {
                    Label("仪表盘", systemImage: "chart.bar.fill")
                }

            StudentListView(viewModel: studentVM)
                .tabItem {
                    Label("学生", systemImage: "person.2.fill")
                }

            LessonListView(viewModel: lessonVM, studentVM: studentVM)
                .tabItem {
                    Label("课程", systemImage: "book.fill")
                }

            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }

            ProgressListView(viewModel: progressVM, studentVM: studentVM)
                .tabItem {
                    Label("进度", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
        .onAppear {
            loadAllData()
        }
    }

    private func loadAllData() {
        studentVM.loadStudents()
        lessonVM.loadLessons()
        progressVM.loadProgressRecords()
        dashboardVM.loadData()
    }
}
