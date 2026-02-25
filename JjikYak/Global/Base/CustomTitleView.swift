import UIKit
import SnapKit

class CustomTitleView: UIView {
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium) // 표준 타이틀 크기
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .left
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 1
        return stack
    }()
    
    override var intrinsicContentSize: CGSize {
        return stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(bottomLabel)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview().offset(2)
        }
    }
    
    // 데이터를 업데이트하는 함수
    func updateTitle(main: String, sub: String? = nil) {
        // 위에 있는 메인 라벨 설정
        topLabel.text = main
        
        // 아래에 있는 서브 라벨 설정
        if let subText = sub, !subText.isEmpty {
            bottomLabel.text = subText
            bottomLabel.isHidden = false
        } else {
            bottomLabel.text = nil
            bottomLabel.isHidden = true // 부제목 없으면 메인 라벨이 수직 중앙 정렬됨
        }
        
        invalidateIntrinsicContentSize()
    }
}
