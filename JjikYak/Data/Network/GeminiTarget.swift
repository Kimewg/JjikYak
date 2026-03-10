import Foundation
import Moya

enum GeminiTarget {
    case parsePillInfo(ocrText: String)
}

extension GeminiTarget: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://generativelanguage.googleapis.com/v1beta/models")!
    }
    
    // gemini 2.5 flash 버전을 사용함
    var path: String {
        switch self {
        case .parsePillInfo:
            return "/gemini-2.5-flash:generateContent"
        }
    }
    
    // 통신 방식 (Method) - 데이터 전송 및 결과 받기(POST)
    var method: Moya.Method {
        return .post
    }
    
    // 헤더 (Headers) -API Key를 꺼내오는 핵심 구간
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "x-goog-api-key": ConfigManager.geminiAPIKey
        ]
    }
    
    // 파라미터 & 바디 (Task) 실제 보낼 내용물
    var task: Task {
        switch self {
        case .parsePillInfo(let ocrText):
            // Gemini API가 요구하는 복잡한 JSON 형식을 딕셔너리로 미리 구성.
            let parameters: [String: Any] = [
                            "contents": [[
                                "parts": [[
                                    "text": """
                                    다음 약 봉투/처방전 OCR 텍스트를 분석하여 약 정보 배열을 JSON 형태로 반환해 줘.

                                    🚨 [제약사항 - 반드시 지킬 것!]
                                    1. 정보의 출처: 절대 너의 사전 배경지식을 사용해서 임의로 지어내지 말고, 오직 제공된 텍스트 내에서만 분석해라.
                                    2. 복용법(dosage): 텍스트에서 명확한 복용법(예: 1일 2회, 1 6 3 등)을 찾을 수 없거나 매칭이 불분명하다면, 절대 임의로 지어내지 말고 무조건 "처방전에 따름" 이라고 작성해라.
                                    3. 효능 및 주의점(efficacy): 약의 기본적인 효능뿐만 아니라, 텍스트에 기재된 '주의사항'(예: 졸음 유발, 위장장애, 커피/유제품 섭취 지양 등)이 있다면 반드시 함께 요약해서 작성해라.
                                    4. 출력 형식: 반드시 마크다운 백틱(```json)을 제외한 순수 JSON 배열만 반환해라.

                                    [출력 JSON 예시]
                                    [
                                      {
                                        "pillName": "알마겔정",
                                        "dosage": "1일 3회 식후 복용",
                                        "efficacy": "제산제. 위장장애 주의, 2시간 이상 간격 투여"
                                      },
                                      {
                                        "pillName": "모르는약이름",
                                        "dosage": "처방전에 따름",
                                        "efficacy": "졸음 유발 주의"
                                      }
                                    ]

                                    [분석할 텍스트]
                                    \(ocrText)
                                    """
                                ]]
                            ]]
                        ]            // 위 딕셔너리를 JSON 바디로 변환해서 보냄
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        
        
    }
}
