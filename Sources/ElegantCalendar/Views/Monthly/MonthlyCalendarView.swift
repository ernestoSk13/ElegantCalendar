// Kevin Li - 2:26 PM - 6/14/20

import ElegantPages
import SwiftUI

@available(iOS 14.0, *)
public struct MonthlyCalendarView: View, MonthlyCalendarManagerDirectAccess {

    var theme: CalendarTheme = .default
    public var axis: Axis = .vertical

    @ObservedObject public var calendarManager: MonthlyCalendarManager
    @State var firstLoad = true

    private var isTodayWithinDateRange: Bool {
        Date() >= calendar.startOfDay(for: startDate) &&
            calendar.startOfDay(for: Date()) <= endDate
    }

    private var isCurrentMonthYearSameAsTodayMonthYear: Bool {
        calendar.isDate(currentMonth, equalTo: Date(), toGranularities: [.month, .year])
    }

    public init(calendarManager: MonthlyCalendarManager) {
        self.calendarManager = calendarManager
    }

    public var body: some View {
        GeometryReader { geometry in
            self.content(geometry: geometry)
        }
    }

    private func content(geometry: GeometryProxy) -> some View {
        CalendarConstants.Monthly.cellWidth = geometry.size.width > 1000 ? geometry.size.width - 500 : geometry.size.width

        return VStack {
            monthsList
        }
    }
    
    private var gridItemLayout = [GridItem(.flexible())]

    private var monthsList: some View {
        Group {
            if axis == .vertical {
//                if #available(iOS 14.0, *) {
//                    LazyVGrid(columns: gridItemLayout) {
//                        ScrollView {
//                                ScrollViewReader { reader in
//                                    ForEach(0 ..< months.count) { monthIndex in
//                                        monthView(for: monthIndex, onScrollToToday: {
//                                            reader.scrollTo(listManager.currentPageIndex, anchor: .top)
//                                        })
//                                            .padding(.vertical, 10)
//                                            .id(monthIndex)
//                                    }.onAppear {
//                                        reader.scrollTo(listManager.currentPageIndex, anchor: .top)
//                                    }
//                                }
//                        }.frame(height: CalendarConstants.cellHeight > 400 ? CalendarConstants.cellHeight * 2 : (CalendarConstants.cellHeight * 2 + 80) )
//                            .transition(.opacity)
//                    }.animation(.none)
//                }
                
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVGrid(columns: gridItemLayout) {
                            ForEach(0 ..< months.count) { monthIndex in
                                monthView(for: monthIndex, onScrollToToday: {
                                    reader.scrollTo(listManager.currentPageIndex, anchor: .top)
                                })
                                    .padding(.vertical, 10)
                                    .id(monthIndex)
                                    .onAppear {
                                        calendarManager.delegate?.calendar(willDisplayMonth: calendarManager.months[monthIndex])
                                    }
                            }
                            .onAppear {
                                guard firstLoad else {
                                    return
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    reader.scrollTo(listManager.currentPageIndex, anchor: .top)
                                    firstLoad = false
                                }
                            }
                        }
                    }
                }.animation(.none)
            }
        }
    }

    private func monthView(for page: Int, onScrollToToday: (() -> ())? = nil) -> AnyView {
        MonthView(calendarManager: calendarManager, month: months[page], onScrollToToday: onScrollToToday)
            .environment(\.calendarTheme, theme)
            .erased
    }

    private var leftAlignedScrollBackToTodayButton: some View {
        HStack {
            Spacer()
            ScrollBackToTodayButton(scrollBackToToday: scrollBackToToday,
                                    color: theme.primary)
        }
    }

}

struct MonthlyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        LightDarkThemePreview {
            if #available(iOS 14.0, *) {
                MonthlyCalendarView(calendarManager: .mock)
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 14.0, *) {
                MonthlyCalendarView(calendarManager: .mockWithInitialMonth)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

private extension PageTurnType {

    static var monthlyEarlyCutoff: PageTurnType = .earlyCutoff(config: .monthlyConfig)

}

public extension EarlyCutOffConfiguration {

    static let monthlyConfig = EarlyCutOffConfiguration(
        scrollResistanceCutOff: 40,
        pageTurnCutOff: 80,
        pageTurnAnimation: .spring(response: 0.3, dampingFraction: 0.95))

}
