import Foundation
import SwiftUI

class WhatsNewManager: ObservableObject {
    @Published var latestVersion: WhatsNewVersion?

    init() {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.latestVersion = WhatsNewStore.allVersions.first { $0.version == current }
    }
}
