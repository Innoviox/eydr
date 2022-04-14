//
//  Extensions.swift
//  eydr2
//
//  Created by Simon Chervenak on 4/14/22.
//

import Foundation
import SwiftUI
import CoreData

public extension Calendar {
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

public extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
    
    func to_tuple() -> (Int, Int, Int) {
        return (self.get(.year), self.get(.month), self.get(.day))
    }
}

public extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

public extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

public extension NSManagedObjectContext {
    func item(for date: DateInfo) -> Item? {
        guard let fetched = allItems() else {
            return nil
        }

        for item in fetched {
            let idc = (item.timestamp ?? Date()).get(.day, .month, .year)
            
            if date.day == idc.day && date.month == idc.month && date.year == idc.year {
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
    
    func getGradientExerciseColor(for date: DateInfo) -> Color {
        let goal = 10.0
                
        guard let data = item(for: date) else {
            return .white
        }
        
        let value = max(0, 1.0 - Double(data.exercise) / goal)
        
        return Color(red: value, green: value, blue: 1.0)
    }
    
    func getTextColor(for date: DateInfo) -> Color {
        guard let data = item(for: date) else {
            return .black
        }
        
        return data.exercise == 0 ? .black : .white
    }
    
    func increment(_ date: DateInfo) -> Int {
        var data = item(for: date)
        if data == nil {
            data = Item(context: self)
            data!.timestamp = date.to_date()
        }
        
        data!.exercise += 1
        
        do {
            try save()
        } catch {
            
        }
        
        return Int(data!.exercise)
    }
    
    func decrement(_ date: DateInfo) -> Int {
        var data = item(for: date)
        if data == nil {
            data = Item(context: self)
            data!.timestamp = date.to_date()
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
                let di = DateInfo(date: date)
                colors[di] = (getGradientExerciseColor(for: di), getTextColor(for: di))
            }
        }
        
        return colors
    }
}
