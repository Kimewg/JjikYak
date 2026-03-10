import UIKit
import SnapKit
import Vision // ✨ 애플의 AI 시력(OCR) 프레임워크 추가!

// ✨ 훈님만의 카메라/갤러리 테스트 전용 뷰 컨트롤러 (나중에 로직만 빼가고 지울 예정!)
final class TestCameraViewController: UIViewController {
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🖼️ 갤러리 테스트", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(galleryButton)
        galleryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 버튼에 갤러리 띄우는 함수 연결
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
    }
    
    // MARK: - 갤러리 띄우기 핵심 로직 (나중에 파트너 UI에 이 함수만 이식할 겁니다!)
    @objc private func openGallery() {
        // 1. 이미지 피커(앨범 화면) 객체 생성
        let imagePicker = UIImagePickerController()
        
        // 2. 소스타입을 '사진 보관함'으로 설정
        imagePicker.sourceType = .photoLibrary
        
        // 3. 내가(TestCameraViewController) 사진 선택 결과를 대신 받을게! (Delegate 연결)
        imagePicker.delegate = self
        
        // 4. 화면에 띄우기!
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - 이미지 피커 결과 처리 (Delegate)
extension TestCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 유저가 사진을 딱! 골랐을 때 실행되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 고른 사진을 UIImage 타입으로 뽑아오기
        if let selectedImage = info[.originalImage] as? UIImage {
            print("✅ 갤러리에서 사진을 성공적으로 가져왔습니다! 크기: \(selectedImage.size)")
            recognizeText(in: selectedImage)
            // 🚨 다음 스텝 예고: 여기서 이 selectedImage를 OCR(글자 추출) 엔진으로 넘길 겁니다!
        }
        
        // 사진 골랐으니 앨범 화면 닫기
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 유저가 사진 고르다 말고 '취소'를 눌렀을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("❌ 유저가 사진 선택을 취소했습니다.")
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 애플 Vision OCR (이미지에서 글자 추출하기)
    private func recognizeText(in image: UIImage) {
        // 1. Vision이 좋아하는 형식(CGImage)으로 사진 변환
        guard let cgImage = image.cgImage else {
            print("❌ 이미지 변환 실패")
            return
        }
        
        // 2. 글자 인식 요청서(Request) 만들기
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("❌ 텍스트 인식 실패: \(error?.localizedDescription ?? "알 수 없는 에러")")
                return
            }
            
            //            // 3. 인식된 조각조각의 글자들을 하나의 긴 문장으로 합치기
            //            let recognizedStrings = observations.compactMap { observation in
            //                return observation.topCandidates(1).first?.string
            //            }
            //            let fullText = recognizedStrings.joined(separator: "\n")
            
            // 3. 텍스트 추출 및 🔒 개인정보 마스킹
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            // 단순히 엔터로 합칩니다.
            var fullText = recognizedStrings.joined(separator: "\n")
            
            // --- 🔒 [보안] 정규식을 활용한 개인정보 마스킹 ---
            // 1) 주민등록번호 패턴 (ex: 900101-1234567 또는 900101 1234567)
            let rrnPattern = "\\d{6}[- ]?\\d{7}"
            // 2) 휴대폰 번호 패턴 (ex: 010-1234-5678)
            let phonePattern = "010[- ]?\\d{4}[- ]?\\d{4}"
            
            if let rrnRegex = try? NSRegularExpression(pattern: rrnPattern, options: []) {
                let range = NSRange(location: 0, length: fullText.utf16.count)
                fullText = rrnRegex.stringByReplacingMatches(in: fullText, options: [], range: range, withTemplate: "******-*******")
            }
            
            if let phoneRegex = try? NSRegularExpression(pattern: phonePattern, options: []) {
                let range = NSRange(location: 0, length: fullText.utf16.count)
                fullText = phoneRegex.stringByReplacingMatches(in: fullText, options: [], range: range, withTemplate: "010-****-****")
            }
            
            print("🔍 [안전한 OCR 텍스트 추출 완료]\n\(fullText)")
            // 이 fullText를 Gemini API로 전송!
            // 4. 결과 출력! (나중엔 이 fullText를 Gemini AI한테 던질 겁니다!)
            print("====================================")
            print("🔍 [OCR 글자 추출 성공!]")
            print(fullText)
            print("====================================")
            
            let geminiService = GeminiService()
            geminiService.parsePillInfo(ocrText: fullText) { result in
                // 네트워크 통신이 끝나고 UI를 건드릴 때는 반드시 Main Thread로 와야 합니다!
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pillInfos):
                        print("✅ [최종 AI 분석 성공!] 총 \(pillInfos.count)개의 약 데이터가 디코딩되었습니다 💊")
                        
                        // 🌟 (보너스) 여기서 바로 아까 만든 결과 화면을 띄워버릴 수도 있습니다!
                        let resultVC = ScanResultViewController()
                        resultVC.pillList = pillInfos
                        resultVC.bindData()
                        
                        // 현재 화면(TestVC) 위에 결과 화면을 모달로 띄우기!
                        self.present(resultVC, animated: true)
                        
                    case .failure(let error):
                        print("❌ [AI 분석 실패]: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // ✨ 한글 인식률을 최대로 끌어올리기 위한 필수 세팅 (iOS 16 이상 권장)
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.recognitionLevel = .accurate // 속도보단 정확도 우선!
        
        // 5. 요청서(Request)를 실행할 핸들러 만들고 실행 쾅!
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("❌ OCR 요청 실패: \(error)")
            
        }
    }
}
