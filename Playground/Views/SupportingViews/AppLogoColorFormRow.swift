//
//  AppLogoColorFormRow.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

#if DEBUG
import SwiftUI

struct AppLogoColorFormRow<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Divider()
            content
        }
    }
}

struct AppLogoColorFormRow_Previews: PreviewProvider {
    static var previews: some View {
        AppLogoColorFormRow(title: "Title") {
            Text("Yes")
        }
    }
}
#endif
