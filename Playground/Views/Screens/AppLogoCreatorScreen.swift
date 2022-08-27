//
//  AppLogoCreatorScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/08/2022.
//

#if DEBUG && swift(>=5.7)
import SwiftUI
import SalmonUI
import ShrimpExtensions

@available(macOS 13.0, *)
private let SCREEN: StackNavigator.Screens = .appLogoCreator
private let logger = Logster(from: AppLogoCreatorScreen.self)

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
                    #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
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
            HStack {
                AppLogoColorFormRow(title: "Curve size") {
                    Stepper("\(Int(viewModel.curvedCornersSize))", value: $viewModel.curvedCornersSize)
                }
                Button(action: { viewModel.curvedCornersSize = 64 }) {
                    Text("mac corners")
                }
                Button(action: { viewModel.curvedCornersSize = 16 }) {
                    Text("iOS corners")
                }
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
        @Published var exportLogoSize = "400" {
            didSet {
                let filteredExportLogoSize = exportLogoSize.filter(\.isNumber)
                if exportLogoSize != filteredExportLogoSize {
                    exportLogoSize = filteredExportLogoSize
                }
            }
        }

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

        #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
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

        func exportLogoAsIconSet() {
            guard let pngData = logoToExport.snapshot().pngData,
                  let temporaryDirectoryURL = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory()]) else {
                return
            }

            switch Shell.runAppIconGenerator(input: pngData, output: temporaryDirectoryURL) {
            case let .failure(failure):
                logger.error(label: "failed to run app icon generator", error: failure)
                return
            case let .success(success):
                logger.info("successfully ran app icon generator; output='\(success)'")
            }

            let iconSetName = "AppIcon.appiconset"
            let iconSetURL: URL?
            do {
                iconSetURL = try FileManager.default.findDirectoryOrFile(
                    inDirectory: temporaryDirectoryURL,
                    searchPath: iconSetName
                )
            } catch {
                logger.error(label: "failed to find directory or file", error: error)
                return
            }
            guard let iconSetURL = iconSetURL else { return }

            Task {
                let (result, panel) = await SavePanel.savePanel(filename: iconSetName)
                var maybeError: Error?
                do {
                    try await onIconSaveBegin(response: result, saveURL: panel.url, iconSetURL: iconSetURL)
                } catch {
                    maybeError = error
                }

                if let maybeError = maybeError {
                    logger.error(label: "failed to save icon set", error: maybeError)

                    do {
                        try FileManager.default.removeItem(at: iconSetURL)
                    } catch {
                        logger.error(label: "failed to remove icon set", error: error)
                    }
                }
            }
        }
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

        #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
        private func onIconSaveBegin(response: NSApplication.ModalResponse, saveURL: URL?, iconSetURL: URL) throws {
            guard response == .OK else {
                logger.warning("could not save file; response='\(response.rawValue)'")
                return
            }

            guard let saveURL = saveURL else { return }

            if FileManager.default.fileExists(atPath: saveURL.path) {
                try FileManager.default.removeItem(at: saveURL)
            }

            try FileManager.default.moveItem(at: iconSetURL, to: saveURL)

            logger.info("file saved")
        }
        #endif
    }
}

#if os(macOS)
extension Shell {
    enum AppIconGeneratorErrors: Error {
        case resourceNotFound(name: String)
        case generalError(error: Error)
        case temporaryFileWentWrong
    }

    @discardableResult
    static func runAppIconGenerator(input: Data, output: URL) -> Result<String, AppIconGeneratorErrors> {
        guard let temporaryFileURL = NSURL.fileURL(withPathComponents: [
            NSTemporaryDirectory(),
            "\(UUID().uuidString).png",
        ]) else {
            return .failure(.temporaryFileWentWrong)
        }

        do {
            try input.write(to: temporaryFileURL)
        } catch {
            return .failure(.generalError(error: error))
        }

        let bundleResourceURL = Bundle.main.resourceURL!
        let appIconGeneratorName = "app-icon-generator"
        let appIconGenerator: URL?
        do {
            appIconGenerator = try FileManager.default.findDirectoryOrFile(
                inDirectory: bundleResourceURL,
                searchPath: appIconGeneratorName
            )
        } catch {
            switch cleanUp(temporaryFileURL: temporaryFileURL) {
            case let .failure(failure): return .failure(failure)
            case .success: break
            }
            return .failure(.generalError(error: error))
        }

        guard let appIconGenerator = appIconGenerator else {
            switch cleanUp(temporaryFileURL: temporaryFileURL) {
            case let .failure(failure): return .failure(failure)
            case .success: break
            }
            return .failure(.resourceNotFound(name: appIconGeneratorName))
        }

        let appIconGeneratorPath = appIconGenerator.relativePath.shellEncodedURL
        let command = "\(appIconGeneratorPath) -o \(output.relativePath) -i \(temporaryFileURL.relativePath) -v"
        let output = Shell.zsh(command)

        switch cleanUp(temporaryFileURL: temporaryFileURL) {
        case let .failure(failure): return .failure(failure)
        case .success: break
        }
        return .success(output)
    }

    private static func cleanUp(temporaryFileURL: URL) -> Result<Void, AppIconGeneratorErrors> {
        do {
            try FileManager.default.removeItem(at: temporaryFileURL)
        } catch {
            return .failure(.generalError(error: error))
        }
        return .success(())
    }
}
#endif

@available(macOS 13.0, *)
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
