//
//  DataSourcePicker.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 09/10/2022.
//

import SwiftUI
import SalmonUI
import SharedModels

struct DataSourcePicker: View {
    @Binding var source: DataSource

    let sources: [DataSource]
    let withLabel: Bool

    init(source: Binding<DataSource>, sources: [DataSource], withLabel: Bool) {
        self._source = source
        self.sources = sources
        self.withLabel = withLabel
    }

    var body: some View {
        Picker(selection: $source, label: Text.empty()) {
            ForEach(sources, id: \.self) { source in
                HStack {
                    if withLabel {
                        Text(source.label)
                    }
                    Image(systemName: source.persistanceMethodImageName)
                }
                .tag(source)
            }
        }
        .labelsHidden()
        .frame(maxWidth: 60)
    }
}

struct DataSourcePicker_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(DataSource.allCases, id: \.self) { source in
            DataSourcePicker(source: .constant(source), sources: DataSource.allCases, withLabel: true)
                .previewLayout(.sizeThatFits)
            DataSourcePicker(source: .constant(source), sources: DataSource.allCases, withLabel: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
