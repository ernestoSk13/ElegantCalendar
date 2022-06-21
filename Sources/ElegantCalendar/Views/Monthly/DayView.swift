// Kevin Li - 11:30 PM - 6/6/20

import SwiftUI
import Combine

struct DayView: View, MonthlyCalendarManagerDirectAccess {

    @Environment(\.calendarTheme) var theme: CalendarTheme

    @ObservedObject var calendarManager: MonthlyCalendarManager
    let selectedDate = NotificationCenter.default.publisher(for: NSNotification.Name("selectedDate"))

    let week: Date
    let day: Date
    @State var bgColor = Color.clear

    private var isDayWithinDateRange: Bool {
        day >= calendar.startOfDay(for: startDate) && day <= endDate
    }

    private var isDayWithinWeekMonthAndYear: Bool {
        calendar.isDate(week, equalTo: day, toGranularities: [.month, .year])
    }

    private var canSelectDay: Bool {
        datasource?.calendar(canSelectDate: day) ?? true
    }

    private var isDaySelectableAndInRange: Bool {
        isDayWithinDateRange && isDayWithinWeekMonthAndYear && canSelectDay
    }

    private var isDayToday: Bool {
        calendar.isDateInToday(day)
    }

    private var isSelected: Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(selectedDate, equalTo: day, toGranularities: [.day, .month, .year])
    }
    
    

    var body: some View {
        Text(numericDay)
            .font(.footnote)
            .foregroundColor(bgColor == .clear ? backgroundColor : Color.white)
            .frame(width: CalendarConstants.Monthly.dayWidth, height: CalendarConstants.Monthly.dayWidth)
            .clipShape(Circle())
            .opacity(opacity)
            .background(Circle().fill(bgColor))
            .overlay(Circle()
                        .stroke(backgroundColor, lineWidth: 2))
            .overlay(isDayToday ? CircularSelectionView(color: backgroundColor) : nil)
            .onTapGesture(perform: notifyManager)
            .onReceive(selectedDate) { object in
                if let output = object.object as? [Date], output.contains(day) {
                    bgColor = backgroundColor
                } else {
                    bgColor = .clear
                }
            }
    }

    private var numericDay: String {
        String(calendar.component(.day, from: day))
    }

    private var foregroundColor: Color {
        if isDayToday {
            return theme.primary
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isDaySelectableAndInRange {
            return datasource?.calendar(colorForDate: day) ?? .primary
        } else {
            return Color.clear
        }
    }

    private var opacity: Double {
        guard !isDayToday else { return 1 }
        return isDaySelectableAndInRange ? 1 : 0.15
    }

    private func notifyManager() {
        guard isDayWithinDateRange && canSelectDay else { return }

        if isDayToday || isDayWithinWeekMonthAndYear {
            calendarManager.dayTapped(day: day, withHaptic: true)
        }
    }

}

private struct CircularSelectionView: View {

    @State private var startBounce = false
    var color: Color = .primary

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .frame(width: radius, height: radius)
            .opacity(startBounce ? 1 : 0)
            .animation(.interpolatingSpring(stiffness: 150, damping: 10))
            .onAppear(perform: startBounceAnimation)
    }

    private var radius: CGFloat {
        startBounce ? CalendarConstants.Monthly.dayWidth + 6 : CalendarConstants.Monthly.dayWidth + 25
    }

    private func startBounceAnimation() {
        startBounce = true
    }

}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        LightDarkThemePreview {
            DayView(calendarManager: .mock, week: Date(), day: Date())

            DayView(calendarManager: .mock, week: Date(), day: .daysFromToday(3))
        }
    }
}
