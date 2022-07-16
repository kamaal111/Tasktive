//
//  ContentView.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Text(localized: .HELLO)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
