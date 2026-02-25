import Foundation

// UI에서 직접 사용할 깔끔한 약 정보 구조체
struct PillInfo: Decodable {
    let pillName: String
    let dosage: String
    let efficacy: String
    
}
