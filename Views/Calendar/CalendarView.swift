import SwiftUI

struct CalendarView: View {
    @StateObject private var lessonVM = LessonViewModel()
    @StateObject private var studentVM = StudentViewModel()
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Header
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()

                // Weekday Headers
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(height: 30)
                    }
                }
                .padding(.horizontal)

                // Calendar Grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            CalendarDayView(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                hasLesson: hasLesson(on: date),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.top)

                // Selected Day Lessons
                VStack(alignment: .leading, spacing: 12) {
                    Text(formatDate(selectedDate))
                        .font(.headline)
                        .padding(.horizontal)

                    if selectedDayLessons.isEmpty {
                        Spacer()
                        Text("当天没有课程")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        ScrollView {
                            ForEach(selectedDayLessons) { lesson in
                                LessonRowView(lesson: lesson)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("日历")
            .onAppear {
                lessonVM.loadLessons()
                studentVM.loadStudents()
            }
        }
    }

    private var weekdays: [String] {
        ["日", "一", "二", "三", "四", "五", "六"]
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月"
        return formatter.string(from: currentMonth)
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []

        // 添加月初之前的空白日期
        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 1..<weekday {
            days.append(nil)
        }

        // 添加当月所有日期
        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    private func changeMonth(by value: Int) {
        currentMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) ?? currentMonth
    }

    private func hasLesson(on date: Date) -> Bool {
        lessonVM.lessons.contains { lesson in
            calendar.isDate(lesson.lessonDate, inSameDayAs: date)
        }
    }

    private var selectedDayLessons: [Lesson] {
        lessonVM.lessons.filter { lesson in
            calendar.isDate(lesson.lessonDate, inSameDayAs: selectedDate)
        }.sorted { $0.lessonTime < $1.lessonTime }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
}
