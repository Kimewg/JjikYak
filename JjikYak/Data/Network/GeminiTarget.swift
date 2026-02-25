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
                        // 프롬프트 엔지니어링으로 AI에게 명령하는 부분, 답변이 마음에 안들면 여기서 수정
                        "text": """
                                                다음은 약 봉투를 OCR로 읽은 텍스트야. 텍스트를 분석해서 약 이름, 복용법, 효능을 추출해줘.
                                                만약 텍스트에 복용법이 안 적혀 있다면 네가 아는 의학 지식으로 추천 복용법을 알려주고, 효능이 안 적혀 있다면 일반적인 효능을 채워 넣어줘.
                                                
                                                [🚨 가장 중요한 규칙]
                                                응답은 약이 1개이든 여러 개이든 반드시 아래의 JSON 배열(Array) 양식으로만 딱 떨어지게 반환해. 
                                                키(Key)값은 한국어로 번역하거나 바꾸지 말고, pillName, dosage, efficacy를 무조건 그대로 사용해!
                                                
                                                [
                                                  {
                                                    "pillName": "추출한 약 이름",
                                                    "dosage": "추출한 복용법",
                                                    "efficacy": "추출한 효능"
                                                  }
                                                ]
                                                
                                                분석할 텍스트: \(ocrText)
                                                """
                    ]]
                ]]
            ]
            // 위 딕셔너리를 JSON 바디로 변환해서 보냄
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        
        
    }
}
