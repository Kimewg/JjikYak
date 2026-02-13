import Foundation
import Moya

final class GeminiService {
    // 1. 우리가 만든 메뉴판(GeminiTarget)을 전담할 웨이터(Provider) 생성
    private let provider = MoyaProvider<GeminiTarget>()
    
    // 2. OCR로 읽은 텍스트를 던져주면, AI가 분석한 결과를 돌려주는 함수
    func parsePillInfo(ocrText: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // 웨이터에게 메뉴판의 'parsePillInfo' 주문을 시킴
        provider.request(.parsePillInfo(ocrText: ocrText)) { result in
            switch result {
            case .success(let response):
                // 🚨 [디버깅용 추가] 구글이 보낸 날것(Raw)의 데이터를 문자열로 먼저 찍어서 확인
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 [구글의 실제 답변]:\n\(rawString)")
                }
                
                do {
                    // 구글의 대답을 GeminiResponse 구조체로 변환(Decoding)
                    let decodedData = try JSONDecoder().decode(GeminiResponse.self, from: response.data)
                    
                    // 결과 텍스트만 쏙 빼서 전달
                    if let resultText = decodedData.candidates.first?.content.parts.first?.text {
                        completion(.success(resultText))
                    } else {
                        let error = NSError(domain: "GeminiError", code: -1, userInfo: [NSLocalizedDescriptionKey: "응답 텍스트가 비어있습니다."])
                        completion(.failure(error))
                    }
                } catch {
                    // 🚨 [디버깅용 추가] 디코딩이 왜 실패했는지 상세 이유를 확인
                    print("💥 [디코딩 실패 상세 이유]: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                // 인터넷이 끊겼거나 통신 자체가 실패했을 때 에러 전달
                completion(.failure(error))
            }
        }
    }
}
