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
