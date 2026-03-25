//
//  Untitled.swift
//  JjikYak
//
//  Created by 김은서 on 3/25/26.
//
import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class DirectAddViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let customNavBar = CustomNavigationBar()
    
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 40
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        imageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약 이름을 입력하세요"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI가 자동으로 효능과 주의사항을 분석합니다"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let pillTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "타이레놀"
        textField.font = .systemFont(ofSize: 18, weight: .medium)
        textField.textColor = .black
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.backgroundColor = .systemGray6.withAlphaComponent(0.3)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let frequentLabel: UILabel = {
        let label = UILabel()
        label.text = "자주 찾는 약"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    private let frequentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let analyzeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("AI로 분석하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        return button
    }()
    
    private let frequentPills = ["타이레놀", "아스피린", "게보린", "판피린"]
    private var frequentButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        customNavBar.configure(
            title: "약 수동 등록",
            subTitle: nil,
            showBackButton: true,
            showBellButton: false
        )
        setupFrequentButtons()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupFrequentButtons() {
        for pillName in frequentPills {
            var config = UIButton.Configuration.filled()
            var titleAttr = AttributedString(pillName)
            titleAttr.font = .systemFont(ofSize: 14, weight: .medium)
            titleAttr.foregroundColor = .darkGray
            config.attributedTitle = titleAttr
            config.baseBackgroundColor = .systemGray6.withAlphaComponent(0.3)
            config.background.cornerRadius = 16
            config.background.strokeColor = .systemGray4
            config.background.strokeWidth = 1
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            
            let button = UIButton(configuration: config)
            
            frequentButtons.append(button)
            frequentStackView.addArrangedSubview(button)
        }
    }
    
    private func configureUI() {
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
        }
        
        let containerView = UIView()
        view.addSubview(containerView)
        
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(pillTextField)
        containerView.addSubview(frequentLabel)
        containerView.addSubview(frequentStackView)
        containerView.addSubview(analyzeButton)
        
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(40)
            $0.leading.trailing.equalToSuperview()
        }
        
        iconBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconBackgroundView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        pillTextField.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }
        
        frequentLabel.snp.makeConstraints {
            $0.top.equalTo(pillTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
        }
        
        frequentStackView.snp.makeConstraints {
            $0.top.equalTo(frequentLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(32)
        }
        
        analyzeButton.snp.makeConstraints {
            $0.top.equalTo(frequentStackView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        customNavBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        for button in frequentButtons {
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.pillTextField.text = button.titleLabel?.text
                })
                .disposed(by: disposeBag)
        }
        
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        analyzeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let text = self?.pillTextField.text, !text.isEmpty else {
                    print("약 이름을 먼저 입력해주세요.")
                    return
                }
                print("입력된 약 이름: \(text) -> AI 분석 뷰로 이동")
            })
            .disposed(by: disposeBag)
    }
}
