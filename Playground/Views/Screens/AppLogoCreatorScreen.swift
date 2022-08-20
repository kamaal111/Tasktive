//
//  AppLogoCreatorScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI
import ShrimpExtensions

private let SCREEN: StackNavigator.Screens = .appLogoCreator

let PLAYGROUND_SELECTABLE_COLORS: [Color] = [
    .black,
    .white,
]

struct AppLogoCreatorScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KJustStack {
                KSection(header: "Logo") {
                    HStack(alignment: .top) {
                        viewModel.logoView(size: .squared(150))
                        Spacer()
                    }
                }
                KSection(header: "Customization") {
                    AppLogoColorFormRow(title: "Has a background") {
                        Toggle(viewModel.hasABackground ? "Yup" : "Nope", isOn: $viewModel.hasABackground)
                    }
                    .padding(.bottom, .medium)
                    .padding(.vertical, .small)
                    AppLogoColorSelector(color: $viewModel.backgroundColor, title: "Background color")
                        .padding(.bottom, .medium)
                    AppLogoColorFormRow(title: "Has curves") {
                        Toggle(viewModel.hasCurves ? "Yup" : "Nope", isOn: $viewModel.hasCurves)
                    }
                    .padding(.bottom, .medium)
                    AppLogoColorFormRow(title: "Curve size") {
                        Stepper("\(viewModel.curvedCornersSize)", value: $viewModel.curvedCornersSize)
                    }
                    .disabled(viewModel.disableCurvesSize)
                }
            }
            #if os(macOS)
            .padding(.vertical, .medium)
            .padding(.horizontal, .medium)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }
    }
}

extension AppLogoCreatorScreen {
    final class ViewModel: ObservableObject {
        @Published var curvedCornersSize: CGFloat = 16
        @Published var hasCurves = true
        @Published var backgroundColor = PLAYGROUND_SELECTABLE_COLORS.first!
        @Published var hasABackground = true

        init() { }

        var disableCurvesSize: Bool {
            !hasCurves
        }

        func logoView(size: CGSize) -> some View {
            AppLogo(
                size: size,
                curvedCornersSize: hasCurves ? curvedCornersSize : nil,
                backgroundColor: hasABackground ? backgroundColor : nil
            )
        }
    }
}

struct AppLogoCreatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppLogoCreatorScreen()
                .navigationTitle(Text(SCREEN.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
#endif
