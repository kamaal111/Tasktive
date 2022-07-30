//
//  AppSection.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

struct AppSection<Content: View>: View {
    let header: String?
    let content: Content

    init(header: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header?.uppercased()
        self.content = content()
    }

    init(header: TasktiveLocale.Keys, @ViewBuilder content: () -> Content) {
        self.init(header: TasktiveLocale.getText(header), content: content)
    }

    var body: some View {
        KJustStack {
            if let header {
                #if os(macOS)
                VStack {
                    Text(header)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .ktakeWidthEagerly(alignment: .leading)
                    content
                }
                #else
                Section(header: Text(header)) {
                    content
                }
                #endif
            } else {
                #if os(macOS)
                content
                #else
                Section {
                    content
                }
                #endif
            }
        }
        #if os(macOS)
        .padding(.horizontal, .medium)
        .padding(.vertical, .small)
        .background(Color(nsColor: .separatorColor))
        .cornerRadius(.small)
        #endif
    }
}

struct AppSection_Previews: PreviewProvider {
    static var previews: some View {
        AppSection(header: .PROGRESS) {
            Text("Content")
        }
    }
}
