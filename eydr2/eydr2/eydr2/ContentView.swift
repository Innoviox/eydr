import SwiftUI
import CoreData

let FONT: Font = .system(size: 60)

typealias Colors = [Date: (Color, Color)]

struct DateInfo: Hashable {
    let year: Int
    let month: Int
    let day: Int
}

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
            bindings[oldValue.zero()]?.2 = false
            bindings[selectedDate.zero()]?.2 = true
            print(selectedDate)
            print(selectedDate.zero())
            print(bindings)
            print(bindings[selectedDate])
        }
    }
    @State var currentCount = 0 {
        didSet {
            if let b = selectedButton {
                print("current count is changing!")
                setColors(for: selectedDate)
//                bindings
//                b.colors.updateColors(viewContext.item(for: selectedDate))
//                b.backgroundColor = viewContext.getGradientExerciseColor(for: selectedDate)
//                b.foregroundColor = viewContext.getTextColor(for: selectedDate)
//                print("set background color", b.backgroundColor)
            }
        }
    }
    @State private var selectedButton: DateButton?
    private static var now = Date() // Cache now
    
//    @State var colors: Colors = [:]
//    @State var foregrounds: [Date: Color] = [:]
//    @State var backgrounds: [Date: Color] = [:]
//    @State var selected: [Date: Bool] = [:]
    @State var bindings: [DateInfo: (Color, Color, Bool)] = [:]
    
    init(calendar: Calendar, viewColors: Colors) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
        
//        self._colors = State(initialValue: viewColors)
        var dict: [(Int, Int, Int): (Color, Color, Bool)] = [:]
        for day in calendar.range(of: .day, in: .month, for: now)! {
            dict[(now.get(.year), now.get(.month), day)] = (.white, .black, false)
        }
        self._bindings = State(initialValue: dict)
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
//        if colors[date] == nil {
//            colors[date] = (.white, .black)
//        }
        
//        if foregrounds[date] == nil {
//            foregrounds[date] = .white
//        }
//
//        if backgrounds[date] == nil {
//            backgrounds[date] = .black
//        }
//
//        selected[date] = false
        
//        bindings[date] = (.white, .black, false)
        
        let df = DateFormatter(dateFormat: "d", calendar: calendar)
        let today = Calendar.current.isDateInToday(date)
//        var button = DateButton(for: date, action: {}, getColors: {}, calendar: self.calendar);
        var button = DateButton(date: date.zero(), today: today, action: {}, dayFormatter: df,
                                binding: self.binding(for: date.zero()))
        
        button.action = {
            selectedDate = date.zero()
            selectedButton = button
        }
//        let c = colors[date] ?? (.white, .black)
//        button.colors.backgroundColor = c.0
//        button.colors.foregroundColor = c.1
        
        return button
    }
    
    func setColors(for date: Date) {
//        colors[date] = (viewContext.getGradientExerciseColor(for: date), viewContext.getTextColor(for: date))
    }
    
    private func binding(for key: Date) -> Binding<(Color, Color, Bool)> {
        return .init(
            get: {
//                if self.bindings[key] == nil {
//                    self.bindings[key] = (.white, .black, false)
//                }
                return self.bindings[key, default: (.white, .black, false)]
                
            },
            set: { self.bindings[key] = $0 })
    }
//
//    private func binding(for key: String) -> Binding<Bool> {
//        return .init(
//            get: { self.tags[key, default: false] },
//            set: { self.tags[key] = $0 })
//    }
//
//    private func binding(for key: String) -> Binding<Bool> {
//        return .init(
//            get: { self.tags[key, default: false] },
//            set: { self.tags[key] = $0 })
//    }
}

public struct DateButton: View {
    public let date: Date
    public let today: Bool
    public  var action: () -> Void
//    public  var getColors: () -> Void
    public let dayFormatter: DateFormatter
    
//    @ObservedObject var colors = ColorsHolder()
//    @Binding var background: Color
//    @Binding var foreground: Color
//    @Binding var selected: Bool
    
    @Binding var binding: (Color, Color, Bool)
    
//    public init(for date: Date, action: @escaping () -> Void, getColors: @escaping () -> Void, calendar: Calendar) {
//        self.date = date
//        self.today = Calendar.current.isDateInToday(date)
//        self.action = action
//        getColors()
//        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
//    }
    
    public var body: some View {
        return Button(action: self.action) {
            Text("00")
                .padding(8)
                .foregroundColor(.clear)
                .background(binding.0)
                .cornerRadius(8)
                .accessibilityHidden(true)
                .overlay(
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(binding.1)
                )
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: today ? 2 : 0)
                    )
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: binding.2 ? 1 : 0)
                    )
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

class ColorsHolder: ObservableObject {
    @Published var backgroundColor = Color.white
    @Published var foregroundColor = Color.black
    
    public func updateColors(_ item: Item?) {
        print("updating colors")
        let goal = 10.0
                
        guard let data = item else {
            backgroundColor = .white
            foregroundColor = .black
            return
        }
        
        let value = max(0, 1.0 - Double(data.exercise) / goal)
        
        backgroundColor = Color(red: value, green: value, blue: 1.0)
        foregroundColor = data.exercise == 0 ? .black : .white
        
        print("updated colors", backgroundColor, foregroundColor)
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
    
//    func zero() -> Date {
//        let hour = 3600 * self.get(.hour)
//        let min = 60 * self.get(.minute)
//        let sec = self.get(.second)
//        let d = Date(timeInterval: -Double(hour + min + sec), since: self)
//        print(self, d, hour, min, sec)
//        return d
//    }
    
    func to_tuple() -> (Int, Int, Int) {
        return (self.get(.year), self.get(.month), self.get(.day))
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
