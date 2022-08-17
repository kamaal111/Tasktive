//
//  PlaygroundScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI

struct PlaygroundScreen: View {
    var body: some View {
        KScrollableForm {
            Text("Hello, World!")
        }
    }
}

struct PlaygroundScreen_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundScreen()
    }
}
#endif
