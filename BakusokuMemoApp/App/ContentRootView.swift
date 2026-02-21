import SwiftUI
import FoundationModels

/// アプリのルートView。
/// Apple Intelligence の availability をチェックし、
/// 非対応デバイスでは AppleIntelligenceErrorView を表示する。
@MainActor
struct ContentRootView: View {

    private var isAIAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    var body: some View {
        if isAIAvailable {
            RootView()
        } else {
            AppleIntelligenceErrorView()
        }
    }
}
