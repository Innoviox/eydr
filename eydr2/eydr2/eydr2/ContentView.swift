import SwiftUI
import CoreData

let FONT: Font = .system(size: 60)

typealias Colors = [Date: (Color, Color)]

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now {
        didSet{
            currentCount = Int(viewContext.item(for: selectedDate)?.exercise ?? 0)
            setColors(for: selectedDate)
        }
    }
    @State var currentCount = 0 {
        didSet {
            if let b = selectedButton {
                b.backgroundColor = viewContext.getGradientExerciseColor(for: selectedDate)
                b.foregroundColor = viewContext.getTextColor(for: selectedDate)
                print("set background color", b.backgroundColor)
            }
        }
    }
    @State var colors = Colors()
    @State private var selectedButton: DateButton?
    private static var now = Date() // Cache now

    init(calendar: Calendar, colors: Colors) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
        
        self.colors = colors
    }

    var body: some View {
        HStack {
            Button(action: {
                currentCount = viewContext.decrement(selectedDate)
                
            }, label: {
                Text("-").font(FONT)
            })
            Text("\(currentCount)").font(FONT)
            Button(action: {
                currentCount = viewContext.increment(selectedDate)
            }, label: {
                Text("+").font(FONT)
            })
        }
            .padding()
            .border(Color.black)
        
        VStack {
            CalendarView(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    makeButton(for: date)
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
        .onAppear {
            print("running appear")
        }
    }
    
    func makeButton(for date: Date) -> some View {
        var button = DateButton(for: date, action: {}, getColors: {}, calendar: self.calendar);
        button.action = {
            selectedDate = date
            selectedButton = button
        }
        button.getColors = {
            guard let c = colors[date] else {
                return
            }
            
            button.backgroundColor = c.0
            button.foregroundColor = c.1
        }
        
        return button
    }
    
    func setColors(for date: Date) {
        colors[date] = (viewContext.getGradientExerciseColor(for: date), viewContext.getTextColor(for: date))
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

public struct DateButton: View {
    private let date: Date
    private let today: Bool
    public  var action: () -> Void
    public  var getColors: () -> Void
    private let dayFormatter: DateFormatter
    
    @State var backgroundColor = Color.white
    @State var foregroundColor = Color.black
    
    public init(for date: Date, action: @escaping () -> Void, getColors: @escaping () -> Void, calendar: Calendar) {
        self.date = date
        self.today = Calendar.current.isDateInToday(date)
        self.action = action
        self.getColors = getColors
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
    }
    
    public var body: some View {
        return Button(action: self.action) {
            Text("00")
                .padding(8)
                .foregroundColor(.clear)
                .background(backgroundColor)
                .cornerRadius(8)
                .accessibilityHidden(true)
                .overlay(
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(foregroundColor)
                )
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: today ? 2 : 0)
                    )
        }.onAppear(perform: getColors)
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

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension NSManagedObjectContext {
    func item(for date: Date) -> Item? {
        guard let fetched = allItems() else {
            return nil
        }

        let cdc = date.get(.day, .month, .year)
        for item in fetched {
            let idc = (item.timestamp ?? Date()).get(.day, .month, .year)
            
            if cdc.day == idc.day && cdc.month == idc.month && cdc.year == idc.year {
                return item
            }
        }
        
        return nil
    }
    
    func allItems() -> [Item]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        do {
            let fetched = try fetch(fetchRequest) as! [Item]
            return fetched
            
        } catch {
            print("Failed to fetch items: \(error)")
        }

        return nil
    }
    
    func getGradientExerciseColor(for date: Date) -> Color {
        let goal = 10.0
                
        guard let data = item(for: date) else {
            return .white
        }
        
        let value = max(0, 1.0 - Double(data.exercise) / goal)
        
        return Color(red: value, green: value, blue: 1.0)
    }
    
    func getTextColor(for date: Date) -> Color {
        guard let data = item(for: date) else {
            return .black
        }
        
        return data.exercise == 0 ? .black : .white
    }
    
    func increment(_ date: Date) -> Int {
        var data = item(for: date)
        if data == nil {
            data = Item(context: self)
            data!.timestamp = date
        }
        
        data!.exercise += 1
        
        do {
            try save()
        } catch {
            
        }
        
        return Int(data!.exercise)
    }
    
    func decrement(_ date: Date) -> Int {
        var data = item(for: date)
        if data == nil {
            data = Item(context: self)
            data!.timestamp = date
        }
        
        data!.exercise -= 1
        
        do {
            try save()
        } catch {
            
        }
        
        return Int(data!.exercise)
    }
    
    func colorMatrix() -> Colors {
        var colors = Colors()
        
        for item in allItems()! {
            if let date = item.timestamp {
                colors[date] = (getGradientExerciseColor(for: date), getTextColor(for: date))
            }
        }

        return colors
    }
}
