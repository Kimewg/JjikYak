import UIKit
import SnapKit

final class ScanResultViewController: UIViewController {
    
    
    var pillList: [PillInfo] = []
    
    // 상단 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "스캔 결과 확인"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    // 하단 '틀려요' 버튼 (회색)
    private let incorrectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("틀려요", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // 하단 '맞아요' 버튼 (파란색)
    private let correctButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("맞아요", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // 하단 버튼 2개를 담을 가로 상자 (StackView)
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually // 5:5 비율 유지
        return stackView
    }()
    
    // "총 N개의 약이 인식되었습니다" 연한 파란색 안내 박스
    private let summaryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // 아주 연한 파란색
        view.layer.cornerRadius = 12
        return view
    }()
    
    // 안내 박스 안의 텍스트
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "총 1개의 약이 인식되었습니다" // (임시 텍스트)
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    // 약 리스트가 길어지면 위아래로 움직이게 해줄 투명한 스크롤
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false // 스크롤바 숨기기
        return scrollView
    }()
    
    private let pillListStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16 // 약 카드들 사이의 여백
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
                
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        
        view.addSubview(summaryContainerView)
        summaryContainerView.addSubview(summaryLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(pillListStackView)
        
        buttonStackView.addArrangedSubview(incorrectButton)
        buttonStackView.addArrangedSubview(correctButton)
        view.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
        }
        
        summaryContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        summaryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(summaryContainerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(buttonStackView.snp.top).offset(-24)
        }
        
        pillListStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview() // 너비를 고정해야 가로로 안 흔들림!
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
    }
            
        // 약 데이터를 넣으면 카드 뷰(UIView)를 만드는 함수
        private func createPillCard(name: String, dosage: String, efficacy: String) -> UIView {
            // 1. 카드의 하얀 바탕 (모서리 둥글게, 살짝 그림자)
            let cardView = UIView()
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 12
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.systemGray5.cgColor // 아주 연한 회색 테두리
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.05 // 은은한 그림자
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            
            // 2. 카드 안에 들어갈 글씨들
            let nameLabel = UILabel()
            nameLabel.text = "💊 \(name)"
            nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
            nameLabel.textColor = .black
            
            let dosageLabel = UILabel()
            dosageLabel.text = "🕒 복용법: \(dosage)"
            dosageLabel.font = .systemFont(ofSize: 14)
            dosageLabel.textColor = .darkGray
            dosageLabel.numberOfLines = 0 // 글이 길면 자동으로 줄바꿈
            
            let efficacyLabel = UILabel()
            efficacyLabel.text = "✨ 효능: \(efficacy)"
            efficacyLabel.font = .systemFont(ofSize: 14)
            efficacyLabel.textColor = .darkGray
            efficacyLabel.numberOfLines = 0
            
            // 3. 글씨들을 위에서 아래로 예쁘게 정렬해 줄 상자
            let contentStack = UIStackView(arrangedSubviews: [nameLabel, dosageLabel, efficacyLabel])
            contentStack.axis = .vertical
            contentStack.spacing = 8
            
            // 4. 카드 바탕 위에 상자 올리기
            cardView.addSubview(contentStack)
            contentStack.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(16) // 카드 테두리에서 안쪽으로 16씩 여백
            }
            
            return cardView
        }
    
        func bindData() {
            // 1. 기존에 그려진 카드가 있다면 싹 다 지우기 (중복 방지 초기화)
            pillListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // 2. 파란색 안내 박스 텍스트 업데이트
            summaryLabel.text = "총 \(pillList.count)개의 약이 인식되었습니다"
            
            // 3. 바구니에 있는 약 개수만큼 카드 찍어내기
            for pill in pillList {
                let card = createPillCard(name: pill.pillName, dosage: pill.dosage, efficacy: pill.efficacy)
                pillListStackView.addArrangedSubview(card)
            }
        }
}
