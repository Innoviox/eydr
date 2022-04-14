//
//  DateButton.swift
//  eydr2
//
//  Created by Simon Chervenak on 4/14/22.
//

import Foundation
import SwiftUI

public struct DateButton: View {
    public let date: DateInfo
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
                    Text(dayFormatter.string(from: date.to_date()))
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
