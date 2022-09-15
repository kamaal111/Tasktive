//
// Created by Jevgeni Rumjantsev on 15/09/2022.
//

import SwiftUI

#if DEBUG
class BasePreviewer {
    @objc class func injected() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController =
            UIHostingController(rootView: ContentView_Previews.previews)
    }
}
#endif
