//
//  CloudKitDataViewerScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG
import SwiftUI

struct CloudKitDataViewerScreen: View {
    @State private var selectedType = ""

    private let recordTypes: [String] = []

    var body: some View {
        DataViewer(selectedType: $selectedType, recordTypes: recordTypes, databaseItems: databaseItems)
    }

    private var databaseItems: [GridItemConfiguration] {
        []
    }
}

struct CloudKitDataViewerScreen_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitDataViewerScreen()
    }
}
#endif
