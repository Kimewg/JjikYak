//
//  CustomAddView.swift
//  JjikYak
//
//  Created by 김은서 on 2/27/26.
//

import UIKit
    
enum AddMethodType {
    case quick
    case direct
}

class AddMethodCardView: UIControl {
    
    private let type: AddMethodType
    
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        // 터치 이벤트를 막지 않도록 설정
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2 // 두 줄 허용
        label.textColor = .darkGray
        return label
    }()
    
    init(type: AddMethodType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
        setupLayout()
        applyTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 16
        layer.borderWidth = 1
        
        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    private func setupLayout() {
        iconBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(64)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconBackgroundView.snp.top).offset(2)
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func applyTheme() {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        
        switch type {
        case .quick:
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
            layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            
            iconBackgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            iconImageView.image = UIImage(systemName: "doc.text", withConfiguration: config)
            iconImageView.tintColor = .systemBlue
            
            titleLabel.text = "빠른 등록"
            titleLabel.textColor = .systemBlue
            subtitleLabel.text = "처방전이나 약봉투를 촬영하여 자동으로\n약 정보를 등록합니다"
            
        case .direct:
            backgroundColor = .white
            layer.borderColor = UIColor.systemGray4.cgColor
            
            iconBackgroundView.backgroundColor = UIColor.systemGray6
            iconImageView.image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
            iconImageView.tintColor = .darkGray
            
            titleLabel.text = "수동 등록"
            titleLabel.textColor = .black
            subtitleLabel.text = "약 이름을 직접 입력하여 AI가 자동으로\n정보를 분석합니다"
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
}
