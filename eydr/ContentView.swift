//
//  ContentView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var counts = [0, 0]
    @State var is0 = [true, true]

    var body: some View {
        makeBox(i: 0)
        makeBox(i: 1)
    }
    
    func makeBox(i: Int) -> AnyView {
        return AnyView(VStack (alignment: .leading) {
            HStack {
                Button(action: {
                    if counts[i] > 0 {
                        counts[i] -= 1
                        is0[i] = counts[i] == 0
                    }
                }, label: {
                    Text("-")
                }).disabled(is0[i])
                Text("\(counts[i])")
                Button(action: {
                    counts[i] += 1
                    is0[i] = counts[i] == 0
                }, label: {
                    Text("+")
                })
            }
            .padding()
        }.border(Color.black))
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
