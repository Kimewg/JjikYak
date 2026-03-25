import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ScanResultViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    var pillList: [PillInfo] = []
    var onConfirm: (([PillInfo]) -> Void)?
    
    // 뒷배경을 어둡게 만들어줄 투명 뷰
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "스캔 결과 확인"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let summaryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let pillStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "스캔된 약 정보가 정확한가요?"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let incorrectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("틀려요", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 14
        return button
    }()
    
    private let correctButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("맞아요", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 14
        return button
    }()
    
    // MARK: - Initialization (팝업 설정)
    init(pillList: [PillInfo]) {
        self.pillList = pillList
        super.init(nibName: nil, bundle: nil)
        //핵심: 배경이 투명하게 보이도록 설정
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindData()
        bindAction()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear // 전체 배경 투명하게
        
        view.addSubview(dimView)
        view.addSubview(containerView)
        
        [titleLabel, summaryContainerView, scrollView, questionLabel, buttonStackView].forEach {
            containerView.addSubview($0)
        }
        
        summaryContainerView.addSubview(summaryLabel)
        scrollView.addSubview(pillStackView)
        
        buttonStackView.addArrangedSubview(incorrectButton)
        buttonStackView.addArrangedSubview(correctButton)
    }
    
    private func setupConstraints() {
            dimView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            containerView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).multipliedBy(0.8)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(32)
                $0.centerX.equalToSuperview()
            }
            
            summaryContainerView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.height.equalTo(56)
            }
            
            summaryLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(20)
            }
            
            scrollView.snp.makeConstraints {
                $0.top.equalTo(summaryContainerView.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview().inset(24)
                
                // 스크롤뷰 높이를 내부 리스트(스택뷰) 길이에 맞추되, 최대 300까지만 커지게 설정
                $0.height.equalTo(pillStackView.snp.height).priority(.high)
                $0.height.lessThanOrEqualTo(300)
            }
            
            pillStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalToSuperview()
            }
            
            questionLabel.snp.makeConstraints {
                $0.top.equalTo(scrollView.snp.bottom).offset(24)
                $0.centerX.equalToSuperview()
            }
            
            buttonStackView.snp.makeConstraints {
                $0.top.equalTo(questionLabel.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.bottom.equalToSuperview().offset(-32)
                $0.height.equalTo(56)
            }
        }
    
    private func bindData() {
        summaryLabel.text = "총 \(pillList.count)개의 약이 인식되었습니다"
        
        for (index, pill) in pillList.enumerated() {
            let pillRow = createPillRowView(index: index + 1, name: pill.pillName)
            pillStackView.addArrangedSubview(pillRow)
        }
    }
    
    // 개별 약 행(Row) 생성
    private func createPillRowView(index: Int, name: String) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.snp.makeConstraints { $0.height.equalTo(64) }
        
        let numberCircle = UIView()
        numberCircle.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        numberCircle.layer.cornerRadius = 14
        
        let numberLabel = UILabel()
        numberLabel.text = "\(index)"
        numberLabel.textColor = .systemBlue
        numberLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .black
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        view.addSubview(numberCircle)
        numberCircle.addSubview(numberLabel)
        view.addSubview(nameLabel)
        
        numberCircle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        numberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(numberCircle.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        return view
    }
    
    private func bindAction() {
        incorrectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("❌ 틀려요 클릭 - 현재 팝업 닫기")
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        correctButton.rx.tap
            .subscribe(onNext: { [weak self] in
                            guard let self = self else { return }
                            
                            // 2. 팝업을 닫으면서(dismiss), 다음 화면으로 가라고 신호(onConfirm)를 보냅니다!
                            self.dismiss(animated: true) {
                                self.onConfirm?(self.pillList)
                            }
            })
            .disposed(by: disposeBag)
    }
}
