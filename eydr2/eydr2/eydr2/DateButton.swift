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

    public let dayFormatter: DateFormatter
    
    @Binding var binding: (Color, Color, Bool)

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
                            .frame(width: 35, height: 35, alignment: .center))
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple, lineWidth: binding.2 ? 2 : 0)
                            .frame(width: today ? 32 : 35, height: today ? 32 : 35, alignment: .center))
        }
    }
}
