//
//  SwiftUIView.swift
//  
//
//  Created by Ernesto Sánchez Kuri on 05/05/21.
//

import SwiftUI
import ElegantPages

@available(iOS 14.0, *)
public struct iPadMonthlyView: View, MonthlyCalendarManagerDirectAccess {
    var theme: CalendarTheme = .default
    public var axis: Axis = .vertical
    @ObservedObject public var calendarManager: MonthlyCalendarManager
    
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
    
    private var columns: [GridItem] = [
            GridItem(.adaptive(minimum: 500), spacing: 10)
        ]
    
    public var body: some View {
        GeometryReader { geometry in
            content(geometry: geometry)
        }
    }
    
    private func content(geometry: GeometryProxy) -> some View {
        CalendarConstants.Monthly.cellWidth = geometry.size.width
        return ZStack(alignment: .top) {
            monthList
        }.frame(height: CalendarConstants.cellHeight)
    }
    
    private var monthList: some View {
        ScrollView {
            ScrollViewReader { reader in
                LazyVGrid(columns: columns, content: {
                    ForEach(months, id: \.self) { month in
                        MonthView(calendarManager: calendarManager,
                                  month: month, forIpad: true)
                            .id("\(month.fullMonth)\(month.year)")
                    }
                })
                .onAppear {
                    reader.scrollTo("\(Date().fullMonth)\(Date().year)")
                }
            }
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        iPadMonthlyView()
//    }
//}
