//
//  AddPillViewController.swift
//  JjikYak
//
//  Created by 김은서 on 2/25/26.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Vision

class AddPillViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let customNavBar = CustomNavigationBar()
    private let quickAddButton = AddMethodCardView(type: .quick)
    private let directAddButton = AddMethodCardView(type: .direct)
    
    // 이미지 피커 컨트롤러 및 API 서비스 추가
    private let imagePicker = UIImagePickerController()
    private let geminiService = GeminiService()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        customNavBar.configure(
            title: "새로운 약 등록",
            subTitle: nil,
            showBackButton: true,
            showBellButton: false
        )
        
        setupImagePicker() // 피커 델리게이트 초기화
        configure()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Setup
    private func setupImagePicker() {
        imagePicker.delegate = self
    }
    
    private func configure() {
        view.addSubview(customNavBar)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(quickAddButton)
        stackView.addArrangedSubview(directAddButton)
        
        customNavBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        quickAddButton.snp.makeConstraints {
            $0.height.equalTo(120)
        }
        
        directAddButton.snp.makeConstraints {
            $0.height.equalTo(120)
        }
    }
    
    private func bind() {
        customNavBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 빠른 등록 버튼 클릭 이벤트: Action Sheet 호출
        quickAddButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.presentPhotoActionSheet()
            })
            .disposed(by: disposeBag)
        
        directAddButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let directAddVC = DirectAddViewController()
                self.navigationController?.pushViewController(directAddVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // Camera & Gallery Action Sheet
    private func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "약 봉투/처방전 스캔", message: "사진을 가져올 방식을 선택해주세요.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "카메라로 촬영", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in
            self?.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("🚨 카메라를 사용할 수 없는 기기입니다.")
            return
        }
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    private func openGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
}

// 이미지 선택 후 AI 파이프라인 (OCR -> Gemini)
extension AddPillViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1. 피커 닫기
        picker.dismiss(animated: true)
        
        // 2. 선택된 이미지 가져오기
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        print("[AI 분석] 로딩 시작...")
        
        // 3. 추출 로직 실행 (TestCameraViewController에서 짰던 핵심 로직)
        processOCRAndGemini(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // Vision OCR + 마스킹 + Gemini API 호출
    private func processOCRAndGemini(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard error == nil, let observations = request.results as? [VNRecognizedTextObservation] else {
                print("OCR 에러: \(String(describing: error))")
                return
            }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            var fullText = recognizedStrings.joined(separator: "\n")
            
            // 🔒 [보안] 개인정보 마스킹
            let rrnPattern = "\\d{6}[- ]?\\d{7}"
            let phonePattern = "010[- ]?\\d{4}[- ]?\\d{4}"
            
            if let rrnRegex = try? NSRegularExpression(pattern: rrnPattern, options: []) {
                fullText = rrnRegex.stringByReplacingMatches(in: fullText, options: [], range: NSRange(location: 0, length: fullText.utf16.count), withTemplate: "******-*******")
            }
            if let phoneRegex = try? NSRegularExpression(pattern: phonePattern, options: []) {
                fullText = phoneRegex.stringByReplacingMatches(in: fullText, options: [], range: NSRange(location: 0, length: fullText.utf16.count), withTemplate: "010-****-****")
            }
            
            print("[1단계] 안전한 텍스트 추출 완료:\n\(fullText)")
            
            //Gemini AI에 분석 요청
            self?.geminiService.parsePillInfo(ocrText: fullText) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pillInfos):
                        print("AI 파싱 완료. 다음 화면으로 넘어갑니다.")
                        
                        // 1. 결과 화면 뷰 컨트롤러 생성 (데이터 넘겨주기)
                        let resultVC = ScanResultViewController(pillList: pillInfos)
                        
                        // 2. 화면 전환
                        //                            self.navigationController?.pushViewController(resultVC, animated: true)
                         self?.present(resultVC, animated: true)
                    case .failure(let error):
                        print("AI 분석 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.recognitionLevel = .accurate
        
        do {
            try handler.perform([request])
        } catch {
            print("Vision Request 실패: \(error)")
        }
    }
}
