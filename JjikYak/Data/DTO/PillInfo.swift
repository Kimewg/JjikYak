import Foundation

// UI에서 직접 사용할 깔끔한 약 정보 구조체
struct PillInfo: Decodable {
    let pillName: String
    let dosage: String
    let efficacy: String
    
    // JSON의 한글 키값("약 이름")을 Swift의 영어 변수명(pillName)과 연결해주는 열쇠
    enum CodingKeys: String, CodingKey {
        case pillName = "약 이름"
        case dosage = "복용법"
        case efficacy = "효능"
    }
}
