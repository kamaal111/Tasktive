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
    .AccentColor,
    .gray,
]

struct AppLogoCreatorScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KJustStack {
                logoSection
                customizationSection
            }
            #if os(macOS)
            .padding(.vertical, .medium)
            .padding(.horizontal, .medium)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }
    }

    private var logoSection: some View {
        KSection(header: "Logo") {
            HStack(alignment: .top) {
                viewModel.logoView(size: 150)
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        KFloatingTextField(
                            text: $viewModel.exportLogoSize,
                            title: "Export logo size",
                            textFieldType: .numbers
                        )
                        HStack {
                            Button(action: { viewModel.setRecommendedLogoSize() }) {
                                Text("Logo size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableLogoSizeButton)
                            Button(action: { viewModel.setRecommendedAppIconSize() }) {
                                Text("Icon size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableAppIconSizeButton)
                        }
                        .padding(.bottom, -(AppSizes.small.rawValue))
                    }
                    #if canImport(Cocoa)
                    HStack {
                        Button(action: viewModel.exportLogo) {
                            Text("Export logo")
                                .foregroundColor(.accentColor)
                        }
                        Button(action: viewModel.exportLogoAsIconSet) {
                            Text("Export logo as IconSet")
                                .foregroundColor(.accentColor)
                        }
                    }
                    #endif
                }
            }
        }
    }

    private var customizationSection: some View {
        KSection(header: "Customization") {
            AppLogoColorFormRow(title: "Has a background") {
                Toggle(viewModel.hasABackground ? "Yup" : "Nope", isOn: $viewModel.hasABackground)
            }
            .padding(.bottom, .medium)
            .padding(.vertical, .small)
            AppLogoColorSelector(color: $viewModel.backgroundColor, title: "Background color")
                .padding(.bottom, .medium)
            AppLogoColorSelector(color: $viewModel.gradientColor, title: "Gradient color")
                .padding(.bottom, .medium)
            AppLogoColorSelector(color: $viewModel.paperColor, title: "Paper color")
                .padding(.bottom, .medium)
            AppLogoColorSelector(color: $viewModel.lineColor, title: "Line color")
                .padding(.bottom, .medium)
            AppLogoColorFormRow(title: "Has curves") {
                Toggle(viewModel.hasCurves ? "Yup" : "Nope", isOn: $viewModel.hasCurves)
            }
            .padding(.bottom, .medium)
            .disabled(viewModel.disableHasCurveToggle)
            AppLogoColorFormRow(title: "Curve size") {
                Stepper("\(Int(viewModel.curvedCornersSize))", value: $viewModel.curvedCornersSize)
            }
            .disabled(viewModel.disableCurvesSize)
        }
    }
}

extension AppLogoCreatorScreen {
    final class ViewModel: ObservableObject {
        @Published var curvedCornersSize: CGFloat = 16
        @Published var hasCurves = true
        @Published var backgroundColor = PLAYGROUND_SELECTABLE_COLORS[2]
        @Published var hasABackground = true
        @Published var paperColor = PLAYGROUND_SELECTABLE_COLORS[1]
        @Published var primaryColor = PLAYGROUND_SELECTABLE_COLORS[2]
        @Published var lineColor = PLAYGROUND_SELECTABLE_COLORS[3]
        @Published var gradientColor = PLAYGROUND_SELECTABLE_COLORS[1]
        @Published var exportLogoSize = "400"

        init() { }

        var disableCurvesSize: Bool {
            !hasCurves || disableHasCurveToggle
        }

        var disableHasCurveToggle: Bool {
            !hasABackground
        }

        var disableLogoSizeButton: Bool {
            exportLogoSize == "400"
        }

        var disableAppIconSizeButton: Bool {
            exportLogoSize == "800"
        }

        #if canImport(Cocoa)
        func exportLogo() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                Task {
                    await self.logoToExport
                        .snapshot()
                        .download(filename: "logo.png")
                }
            }
        }

        func exportLogoAsIconSet() { }
        #endif

        @MainActor
        func setRecommendedLogoSize() {
            withAnimation { exportLogoSize = "400" }
        }

        @MainActor
        func setRecommendedAppIconSize() {
            withAnimation { exportLogoSize = "800" }
        }

        func logoView(size: CGFloat) -> some View {
            AppLogo(
                size: size,
                curvedCornersSize: hasCurves ? curvedCornersSize : nil,
                backgroundColor: hasABackground ? backgroundColor : nil,
                gradientColor: gradientColor,
                paperColor: paperColor,
                primaryColor: primaryColor,
                lineColor: lineColor
            )
        }

        private var logoToExport: some View {
            let size = Double(exportLogoSize)!.cgFloat
            return logoView(size: size)
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
