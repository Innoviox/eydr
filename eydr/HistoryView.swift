//
//  HistoryView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData
import ExytePopupView

func makeBarHeights(_ items: [Item], getter: (Item) -> CGFloat) -> [CGFloat] {
    let heights = items.map(getter)

    let /* min = heights.min() ?? 0, */ max = heights.max() ?? 0


    return heights.map { $0 / (max == 0 ? 1 : max) * 200 }
}

struct BarView: View {

    var value: CGFloat
    var cornerRadius: CGFloat

    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: 200).foregroundColor(.white)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: value).foregroundColor(.green)

            }.padding(.bottom, 8)
        }

    }
}

struct HistoryView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.managedObjectContext) private var viewContext
    @State var showingPopup = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            loadData()
        }.popup(isPresented: $showingPopup, closeOnTapOutside: true) {
            HStack {
                Text("The popup")
            }
                .frame(width: 200, height: 60)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                .background(Color(hex: "ffffff"))
                .border(Color.red, width: 5)
        }
    }

    func loadData() -> AnyView {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            var fetched = try viewContext.fetch(fetchRequest) as! [Item]
            fetched.sort { $0.timestamp! < $1.timestamp! }

            let topHeights = makeBarHeights(fetched) { CGFloat($0.morning + $0.afternoon) }
            let botHeights = makeBarHeights(fetched) { CGFloat($0.steps) }

            print(topHeights, botHeights)

            return AnyView(
                HStack {
                    ForEach(0..<fetched.count, id: \.self) { i in
                        let item = fetched[i]
                        VStack {
                            BarView(value: topHeights[i], cornerRadius: 1)
                            Text("\(item.timestamp!.get(.day))")
                                .padding(8)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .onTapGesture {
                                    self.showingPopup.toggle()
                            }
                            BarView(value: botHeights[i], cornerRadius: 1)
                        }
                    }
                }
            )
        } catch {
            print("Failed to fetch items: \(error)")
        }

        return AnyView(HStack { Text("Hello, World!") })
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail")
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
