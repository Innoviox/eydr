//
//  HistoryView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData
import ExytePopupView
import MapKit

func makeBarHeights(_ items: [Item], getter: (Item) -> CGFloat) -> [CGFloat] {
    let heights = items.map(getter)

    let /* min = heights.min() ?? 0, */ max = heights.max() ?? 0


    return heights.map { $0 / (max == 0 ? 1 : max) * 200 }
}

struct BarView: View {

    var value: CGFloat
    var cornerRadius: CGFloat
    var direction: Int // 0 up, 1 down
    
    var colors: [Color] = [.white, .green]

    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: 200).foregroundColor(colors[direction])
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: direction == 0 ? value : 200 - value).foregroundColor(colors[1 - direction])
            }.padding(.bottom, 8)
        }
    }
}

struct HistoryView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var locationManager = LocationManager()

    @State var showingPopup = false
    @State var selected: Item?
    @State var route: [CLLocationCoordinate2D] = [] {
        didSet {
            locationManager.time = selected!.time
            locationManager.length = selected!.length

            locationManager.route = route
            locationManager.polyline = MKPolyline(coordinates: route, count: route.count)
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            loadData()
        }.popup(isPresented: $showingPopup, closeOnTapOutside: true) {
            VStack {
                HStack {
                    HStack {
                        Text("\(selected?.morning ?? 0)").font(FONT)
                    }
                        .padding()
                        .border(Color.black)

                    HStack {
                        Text("\(selected?.afternoon ?? 0)").font(FONT)
                    }
                        .padding()
                        .border(Color.black)
                }

                MapView(route: $locationManager.polyline, locationManager: locationManager)
                    .border(Color.black)
                    .overlay(VStack {
                        Text(locationManager.infoString).font(MONO)
                        }
                        .padding()
                        .border(Color.black),
                    alignment: .topLeading)

                HStack {
                    Label {
                        Text("\(selected?.steps ?? 0)")
                            .font(.title)
                    } icon: {
                        Image("shoes")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                    .padding()
                    .border(Color.black)
            }
//                .frame(width: 200, height: 60)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                .background(Color(hex: "ffffff"))
                .border(Color.red, width: 5)
//                .isHidden(showingPopup)
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
                            BarView(value: topHeights[i], cornerRadius: 1, direction: 0)
                            Text("\(item.timestamp!.get(.day))")
                                .padding(8)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .onTapGesture {
                                    self.selected = item
                                    self.showingPopup.toggle()

                                    do {
                                        let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(selected!.route as! Data) as! Route
                                        self.route = data.toRoute()
                                    } catch {
                                        print("areo")
                                    }
                            }
                            BarView(value: botHeights[i], cornerRadius: 1, direction: 1)
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

extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
