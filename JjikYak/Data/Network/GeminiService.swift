import Foundation
import Moya

final class GeminiService {
    private let provider = MoyaProvider<GeminiTarget>()
    
    func parsePillInfo(ocrText: String, completion: @escaping (Result<PillInfo, Error>) -> Void) {
        
        provider.request(.parsePillInfo(ocrText: ocrText)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(GeminiResponse.self, from: response.data)
                    
                    if let resultText = decodedData.candidates.first?.content.parts.first?.text {
                        
                        // 마크다운 포장지 청소 (```json, ```, 줄바꿈 제거)
                        var cleanJSONString = resultText.replacingOccurrences(of: "```json\n", with: "")
                        cleanJSONString = cleanJSONString.replacingOccurrences(of: "```", with: "")
                        cleanJSONString = cleanJSONString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // 깨끗해진 문자열을 다시 Data 타입으로 변환
                        guard let jsonData = cleanJSONString.data(using: .utf8) else {
                            let error = NSError(domain: "ParseError", code: -2, userInfo: [NSLocalizedDescriptionKey: "문자열 변환 실패"])
                            completion(.failure(error))
                            return
                        }
                        
                        // PillInfo 구조체로 변환
                        let pillInfo = try JSONDecoder().decode(PillInfo.self, from: jsonData)
                        
                        // UI로 객체 전달
                        completion(.success(pillInfo))
                        
                    } else {
                        let error = NSError(domain: "GeminiError", code: -1, userInfo: [NSLocalizedDescriptionKey: "응답 텍스트가 비어있습니다."])
                        completion(.failure(error))
                    }
                } catch {
                    print("[디코딩 실패 상세 이유]: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
