//
//  ScrollableForm.swift
//
//
//  Created by Kamaal M Farah on 16/08/2022.
//

import SwiftUI

struct ScrollableForm<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        #if os(macOS)
        ScrollView(.vertical, showsIndicators: true) {
            content
        }
        #else
        Form {
            content
        }
        #endif
    }
}

struct ScrollableForm_Previews: PreviewProvider {
    static var previews: some View {
        ScrollableForm {
            Text("Text")
        }
    }
}
