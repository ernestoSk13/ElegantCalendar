// Kevin Li - 10:53 PM - 6/6/20

import SwiftUI

struct MonthView: View, MonthlyCalendarManagerDirectAccess {

    @Environment(\.calendarTheme) var theme: CalendarTheme

    @ObservedObject var calendarManager: MonthlyCalendarManager

    let month: Date
    
    var forIpad = false
    
    var onScrollToToday: (() -> ())? = nil

    private var weeks: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        return calendar.generateDates(
            inside: monthInterval,
            matching: calendar.firstDayOfEveryWeek)
    }

    private var isWithinSameMonthAndYearAsToday: Bool {
        calendar.isDate(month, equalTo: Date(), toGranularities: [.month, .year])
    }

    var body: some View {
        VStack(spacing: 40) {
            HStack {
                monthYearHeader
                    .padding(.leading, CalendarConstants.Monthly.outerHorizontalPadding)
                    .onTapGesture { self.communicator?.showYearlyView() }
                Button {
                    onScrollToToday?()
                } label: {
                    Image.uTurnLeft
                        .resizable()
                        .frame(width: 30, height: 25)
                        .foregroundColor(Color.primary)
                }.padding(.horizontal, 10)
            }
            weeksViewWithDaysOfWeekHeader
        }
        .padding(.top, CalendarConstants.Monthly.topPadding)
        .frame(width: CalendarConstants.Monthly.cellWidth,
               height: CalendarConstants.cellHeight > 400 ? CalendarConstants.cellHeight : CalendarConstants.cellHeight + 80)
    }

}

private extension MonthView {

    var monthYearHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                monthText
                yearText
            }
            Spacer()
        }
    }

    var monthText: some View {
        Text(month.fullMonth.uppercased())
            .font(.system(size: 26))
            .bold()
            .tracking(7)
            .foregroundColor(.primary)
    }

    var yearText: some View {
        Text(month.year)
            .font(.system(size: 12))
            .tracking(2)
            .foregroundColor(.gray)
            .opacity(0.95)
    }

}

private extension MonthView {

    var weeksViewWithDaysOfWeekHeader: some View {
        VStack(spacing: 32) {
            daysOfWeekHeader
            weeksViewStack
        }
    }

    var daysOfWeekHeader: some View {
        HStack(spacing: CalendarConstants.Monthly.gridSpacing) {
            ForEach(calendar.dayOfWeekInitials, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .font(.caption)
                    .frame(width: CalendarConstants.Monthly.dayWidth)
                    .foregroundColor(.gray)
            }
        }
    }

    var weeksViewStack: some View {
        VStack(spacing: CalendarConstants.Monthly.gridSpacing) {
            ForEach(weeks, id: \.self) { week in
                WeekView(calendarManager: self.calendarManager, week: week)
            }
        }
    }

}

private extension MonthView {

    var calenderAccessoryView: some View {
        CalendarAccessoryView(calendarManager: calendarManager)
    }

}

private struct CalendarAccessoryView: View, MonthlyCalendarManagerDirectAccess {

    let calendarManager: MonthlyCalendarManager

    @State private var isVisible = false

    private var numberOfDaysFromTodayToSelectedDate: Int {
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate ?? Date())
        return calendar.dateComponents([.day], from: startOfToday, to: startOfSelectedDate).day!
    }

    private var isNotYesterdayTodayOrTomorrow: Bool {
        abs(numberOfDaysFromTodayToSelectedDate) > 1
    }

    var body: some View {
        VStack {
            selectedDayInformationView
            GeometryReader { geometry in
                self.datasource?.calendar(viewForSelectedDate: self.selectedDate,
                                          dimensions: geometry.size)
            }
        }
        .onAppear(perform: makeVisible)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.5))
    }

    private func makeVisible() {
        isVisible = true
    }

    private var selectedDayInformationView: some View {
        HStack {
            VStack(alignment: .leading) {
                dayOfWeekWithMonthAndDayText
                if isNotYesterdayTodayOrTomorrow {
                    daysFromTodayText
                }
            }
            Spacer()
        }
    }

    private var dayOfWeekWithMonthAndDayText: some View {
        let monthDayText: String
        
        if selectedDate == nil {
            monthDayText = "Notas del mes"
        } else if numberOfDaysFromTodayToSelectedDate == -1 {
            monthDayText = "Ayer"
        } else if numberOfDaysFromTodayToSelectedDate == 0 {
            monthDayText = "Hoy"
        } else if numberOfDaysFromTodayToSelectedDate == 1 {
            monthDayText = "Mañana"
        } else {
            monthDayText = selectedDate!.dayOfWeekWithMonthAndDay
        }

        return Text(monthDayText.uppercased())
            .font(.subheadline)
            .bold()
    }

    private var daysFromTodayText: some View {
        let isBeforeToday = numberOfDaysFromTodayToSelectedDate < 0
        let daysDescription = isBeforeToday ? "Días Atrás" : "días adelante"

        return Text("\(abs(numberOfDaysFromTodayToSelectedDate)) \(daysDescription)")
            .font(.system(size: 10))
            .foregroundColor(.gray)
    }

}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        LightDarkThemePreview {
            MonthView(calendarManager: .mock, month: Date())

            MonthView(calendarManager: .mock, month: .daysFromToday(45))
        }
    }
}
