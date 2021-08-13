import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        let a = loaddata()
        
        VStack {
            Text("Selected date: \(fullFormatter.string(from: selectedDate))")
                .bold()
                .foregroundColor(.red)
            CalendarView(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button(action: { selectedDate = date }) {
                        Text("00")
                            .padding(8)
                            .foregroundColor(.clear)
                            .background(
                                calendar.isDate(date, inSameDayAs: selectedDate) ? Color.red
                                    : calendar.isDateInToday(date) ? .green
                                    : .blue
                            )
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(.white)
                            )
                    }
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.secondary)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                },
                title: { date in
                    HStack {
                        Text(monthFormatter.string(from: date))
                            .font(.headline)
                            .padding()
                        Spacer()
                        Button {
                            withAnimation {
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: -1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: { Image(systemName: "chevron.left") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                        Button {
                            withAnimation {
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: 1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: { Image(systemName: "chevron.right") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .padding(.bottom, 6)
                }
            )
            .equatable()
        }
        .padding()
    }
    
    func loaddata() {
        let data_string = """
        2021 1 23 0 0
        2021 1 24 1 1
        2021 1 25 2 0
        2021 2 1 3 0
        2021 2 5 0 0
        2021 2 9 0 0
        2021 2 12 0 3
        2021 2 13 0 1
        2021 2 14 0 2
        2021 2 15 1 2
        2021 2 16 2 2
        2021 2 17 0 1
        2021 2 18 2 1
        2021 2 20 3 0
        2021 2 21 5 2
        2021 2 22 3 2
        2021 2 23 3 0
        2021 2 24 0 0
        2021 2 26 2 0
        2021 2 27 0 3
        2021 2 28 2 3
        2021 3 1 2 0
        2021 3 2 3 0
        2021 3 3 0 0
        2021 3 4 3 0
        2021 3 5 0 0
        2021 3 6 5 0
        2021 3 7 3 0
        2021 3 8 2 0
        2021 3 9 0 0
        2021 3 11 3 0
        2021 3 13 0 0
        2021 3 15 0 0
        2021 3 21 5 0
        2021 3 22 5 0
        2021 3 23 5 0
        2021 3 25 5 0
        2021 3 26 1 0
        2021 3 28 5 0
        2021 3 29 4 0
        2021 3 30 5 0
        2021 3 31 5 0
        2021 4 1 5 0
        2021 4 4 6 0
        2021 4 6 5 0
        2021 4 9 5 0
        2021 4 10 5 6
        2021 4 11 5 0
        2021 4 13 5 0
        2021 4 14 5 0
        2021 4 18 5 0
        2021 4 20 5 0
        2021 4 22 5 0
        2021 4 23 0 0
        2021 4 25 5 0
        2021 4 26 5 0
        2021 4 27 5 5
        2021 4 29 5 5
        2021 4 30 5 0
        2021 5 1 5 0
        2021 5 2 5 0
        2021 5 3 5 5
        2021 5 4 5 0
        2021 5 5 5 0
        2021 5 6 5 5
        2021 5 7 5 0
        2021 5 8 5 0
        2021 5 10 5 0
        2021 5 11 5 0
        2021 5 12 6 0
        2021 5 13 6 0
        2021 5 14 6 5
        2021 5 21 4 0
        2021 5 23 4 0
        2021 5 24 5 0
        2021 6 2 5 0
        2021 6 6 0 0
        2021 6 7 5 0
        2021 6 8 4 3
        2021 6 9 4 3
        2021 6 10 5 2
        2021 6 13 4 0
        2021 6 14 4 4
        2021 6 15 4 4
        2021 6 16 5 5
        2021 6 17 5 0
        2021 6 20 5 0
        2021 6 21 5 5
        2021 6 22 5 0
        2021 6 23 5 5
        2021 6 24 5 0
        2021 6 25 5 0
        2021 6 28 5 0
        2021 6 29 5 5
        2021 6 30 5 5
        2021 7 1 5 5
        2021 7 3 5 0
        2021 7 4 5 5
        2021 7 5 5 0
        2021 7 6 5 5
        2021 7 7 5 5
        2021 7 8 5 5
        2021 7 9 5 0
        2021 7 12 5 5
        2021 7 13 5 5
        2021 7 14 5 5
        2021 7 16 5 0
        2021 7 17 2 0
        2021 7 20 5 5
        2021 7 21 5 0
        2021 7 22 5 0
        2021 7 26 5 0
        2021 7 27 5 0
        2021 7 28 5 0
        2021 7 29 5 0
        2021 8 3 5 0
        2021 8 4 5 0
        2021 8 5 5 5
"""
        
        let calendar = Calendar.current

        var items: [Item] = []
        
        for line in data_string.split(separator: "\n") {
            var data = line.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
            
            var dateComponents: DateComponents? = calendar.dateComponents([.year, .month, .day], from: Date())

            dateComponents?.day = Int(data[2])
            dateComponents?.month = Int(data[1])
            dateComponents?.year = Int(data[0])

            let date: Date? = calendar.date(from: dateComponents!)
            
            var total = Int(data[3])! + Int(data[4])!
            
            var item = Item(context: viewContext)
            item.timestamp = date
            item.exercise = Int16(total)
            item.bike_dist = 0
            item.bike_time = 0
            
            items.append(item)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("error saving \(error)")
        }
    }
}

// MARK: - Component

public struct CalendarView<Day: View, Header: View, Title: View, Trailing: View>: View {
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title

    // Constants
    private let daysInWeek = 7

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
    }

    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()

        return LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
            Section(header: title(month)) {
                ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        content(date)
                    } else {
                        trailing(date)
                    }
                }
            }
        }
    }
}

// MARK: - Conformances

extension CalendarView: Equatable {
    public static func == (lhs: CalendarView<Day, Header, Title, Trailing>, rhs: CalendarView<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarView {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}
