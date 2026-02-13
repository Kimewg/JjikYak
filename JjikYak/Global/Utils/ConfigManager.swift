import Foundation

struct ConfigManager {
    static var geminiAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GEMINI_API_KEY"] as? String else {
            fatalError("🚨 CRITICAL: Secrets.plist를 찾을 수 없거나 'GEMINI_API_KEY'가 누락되었습니다!")
        }
        return key
    }
}
