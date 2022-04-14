//
//  Utils.swift
//  eydr2
//
//  Created by Simon Chervenak on 4/14/22.
//

import Foundation
import SwiftUI

let FONT: Font = .system(size: 60)
let calendar = Calendar(identifier: .gregorian)
public struct DateInfo: Hashable {
    let year: Int
    let month: Int
    let day: Int
    
    init(date: Date) {
        year = date.get(.year)
        month = date.get(.month)
        day = date.get(.day)
    }
    
    init(date: Date, day: Int) {
        year = date.get(.year)
        month = date.get(.month)
        self.day = day
    }
    
    func to_date() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        return calendar.date(from: dateComponents)!
    }
}

public typealias Colors = [DateInfo: (Color, Color)]

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
