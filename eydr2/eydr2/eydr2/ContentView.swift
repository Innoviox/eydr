import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = DateInfo(date: Self.now) {
        didSet{
            print("selected date is changing")
            currentCount = Int(viewContext.item(for: selectedDate)?.exercise ?? 0)

            // update is-selected binding
            bindings[oldValue]?.2 = false
            bindings[selectedDate]?.2 = true
        }
    }
    @State var currentCount = 0 {
        didSet {
            if let b = selectedButton {
                print("current count is changing!")
                setColors(for: selectedDate)
            }
        }
    }
    @State private var selectedButton: DateButton?
    private static var now = Date() // Cache now

    @State var bindings: [DateInfo: (Color, Color, Bool)] = [:]
    
    init(calendar: Calendar, viewColors: Colors) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
        
        var dict: [DateInfo: (Color, Color, Bool)] = [:]
       
        for day in calendar.range(of: .day, in: .month, for: ContentView.now)! {
            let di = DateInfo(date: ContentView.now, day: day)
            let def = viewColors[di] ?? (.white, .black)
            dict[di] = (def.0, def.1, day == ContentView.now.get(.day))
        }
        self._bindings = State(initialValue: dict)
        print(self._bindings)
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
                    makeButton(for: DateInfo(date: date))
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
                                    to: selectedDate.to_date()
                                ) else {
                                    return
                                }

                                selectedDate = DateInfo(date: newDate)
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
                                    to: selectedDate.to_date()
                                ) else {
                                    return
                                }

                                selectedDate = DateInfo(date: newDate)
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
    
    func makeButton(for date: DateInfo) -> some View {
        let df = DateFormatter(dateFormat: "d", calendar: calendar)
        let today = Calendar.current.isDateInToday(date.to_date())
        var button = DateButton(date: date, today: today, action: {}, dayFormatter: df,
                                binding: self.binding(for: date))
        
        button.action = {
            selectedDate = date
            selectedButton = button
        }

        return button
    }
    
    func setColors(for date: DateInfo) {
        bindings[date]?.0 = viewContext.getGradientExerciseColor(for: date)
        bindings[date]?.1 = viewContext.getTextColor(for: date)
    }
    
    private func binding(for key: DateInfo) -> Binding<(Color, Color, Bool)> {
        return .init(
            get: {
                return self.bindings[key, default: (.white, .black, false)]
            },
            set: { self.bindings[key] = $0 })
    }
}
