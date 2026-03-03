import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasLesson: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isSelected || isToday ? .bold : .regular)
                .foregroundColor(textColor)

            if hasLesson {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(8)
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
}

#Preview {
    HStack {
        CalendarDayView(date: Date(), isSelected: false, hasLesson: true, isToday: false)
        CalendarDayView(date: Date(), isSelected: true, hasLesson: true, isToday: false)
        CalendarDayView(date: Date(), isSelected: false, hasLesson: false, isToday: true)
    }
    .padding()
}
