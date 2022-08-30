//
//  CloudKitDataViewerScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG
import SwiftUI
import Skypiea

struct CloudKitDataViewerScreen: View {
    @State private var selectedType = CloudTask.recordType

    private let recordTypes: [String] = [
        CloudTask.recordType,
    ]

    var body: some View {
        DataViewer(
            selectedType: $selectedType,
            recordTypes: recordTypes,
            databaseItems: databaseItems,
            fetchData: { Task { await fetchData() } }
        )
    }

    private var databaseItems: [GridItemConfiguration] {
        switch selectedType {
        case CloudTask.recordType:
            return []
        default:
            return []
        }
    }

    private func fetchData() async {
        switch selectedType {
        case CoreTask.description():
            break
        default:
            break
        }
    }
}

struct CloudKitDataViewerScreen_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitDataViewerScreen()
    }
}
#endif
