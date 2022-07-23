//
//  LoadingView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI
import SalmonUI

struct LoadingView: View {
    var body: some View {
        #if os(macOS)
        KActivityIndicator(isAnimating: .constant(true), style: .spinning)
        #else
        KActivityIndicator(isAnimating: .constant(true), style: .large)
        #endif
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
