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

class ColorInfo: ObservableObject {
    @Published var backgroundColor = Color.white
    @Published var foregroundColor = Color.black
    @Published var selected = false
    
    init(_ backgroundColor: Color, _ foregroundColor: Color, _ selected: Bool) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.selected = selected
    }
}


public typealias Colors = [DateInfo: (Color, Color)]
