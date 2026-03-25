//
//  AddPillDetailViewController.swift
//  JjikYak
//
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class AddPillDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 핵심 데이터 (상태 관리)
    private var pillList: [PillInfo]
    private var currentIndex: Int = 0 // 현재 보고 있는 약의 인덱스
    
    // MARK: - UI Components (상단 고정 영역)
    private let topContainerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "처방 정보 확인"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = UIColor.systemGray5
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    // MARK: - UI Components (스크롤 영역)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // 이 스택뷰 안에 효능, 주의사항, 시간 설정 카드들이 차곡차곡 들어갈 예정입니다!
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let pillNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - UI Components (하단 고정 버튼)
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음 >", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Initialization
    init(pillList: [PillInfo]) {
        self.pillList = pillList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        // 화면이 켜지면 첫 번째(0번) 약 데이터를 화면에 뿌려줍니다!
        updateUIForCurrentIndex()
        bindAction()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(topContainerView)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(progressLabel)
        topContainerView.addSubview(progressBar)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // 스택뷰에 약 이름 라벨 추가 (나머지 카드들은 다음 스텝에서 여기에 추가됩니다!)
        contentStackView.addArrangedSubview(pillNameLabel)
        
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        topContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        progressBar.snp.makeConstraints {
            $0.top.equalTo(progressLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(4)
        }
        
        // 스크롤 뷰는 상단 바와 하단 버튼 사이에 꽉 차게!
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(24)
            $0.width.equalToSuperview().offset(-48) // 좌우 여백 24씩 뺌
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    // MARK: - Core Logic: 화면 갈아끼우기
    private func updateUIForCurrentIndex() {
        // 방어 로직: 인덱스가 배열 크기를 넘어가면 크래시 나므로 막아줌
        guard currentIndex < pillList.count else { return }
        
        let currentPill = pillList[currentIndex]
        
        // 1. 상단 프로그레스 텍스트 & 바 업데이트
        progressLabel.text = "\(currentIndex + 1) / \(pillList.count) 번째 약"
        let progressRatio = Float(currentIndex + 1) / Float(pillList.count)
        progressBar.setProgress(progressRatio, animated: true)
        
        // 2. 약 이름 업데이트
        // (훈님의 PillInfo 구조체 변수명에 맞게 currentPill.name 또는 currentPill.pillName 으로 변경해주세요!)
        pillNameLabel.text = currentPill.pillName
        
        // 3. 버튼 텍스트 업데이트 (마지막 약이면 '저장하기'로 변경!)
        if currentIndex == pillList.count - 1 {
            nextButton.setTitle("저장하기", for: .normal)
            nextButton.backgroundColor = .systemGreen
        } else {
            nextButton.setTitle("다음 >", for: .normal)
            nextButton.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Action Binding
    private func bindAction() {
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.currentIndex < self.pillList.count - 1 {
                    // 💡 아직 다음 약이 남아있다면? -> 인덱스를 올리고 화면 갱신!
                    self.currentIndex += 1
                    UIView.animate(withDuration: 0.3) {
                        self.updateUIForCurrentIndex()
                        self.view.layoutIfNeeded()
                    }
                } else {
                    // 💡 마지막 약까지 다 확인했다면? -> 서버에 전송하고 뷰 닫기!
                    print("✅ 최종 데이터 저장 로직 실행: \(self.pillList)")
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}
