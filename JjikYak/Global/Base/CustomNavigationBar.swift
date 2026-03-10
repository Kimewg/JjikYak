//
//  CustomNavigationBar.swift
//  JjikYak
//
//  Created by 김은서 on 3/9/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CustomNavigationBar: UIView {
    
    let disposeBag = DisposeBag()
    
    let backButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        return button
    }()
    
    let bellButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        return button
    }()
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBlue
        
        addSubview(backButton)
        addSubview(bellButton)
        addSubview(titleStackView)
        
        titleStackView.addArrangedSubview(mainTitleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.height.equalTo(32)
        }
        
        bellButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.height.equalTo(32)
        }
    }
    
    func configure(title: String, subTitle: String? = nil, showBackButton: Bool = false, showBellButton: Bool = false) {
        mainTitleLabel.text = title
        
        if let subTitle = subTitle {
            subTitleLabel.text = subTitle
            subTitleLabel.isHidden = false
        } else {
            subTitleLabel.isHidden = true
        }
        
        backButton.isHidden = !showBackButton
        bellButton.isHidden = !showBellButton
        
        titleStackView.snp.remakeConstraints {
            if showBackButton {
                $0.leading.equalTo(backButton.snp.trailing).offset(12)
            } else {
                $0.leading.equalToSuperview().offset(20)
            }
            
            $0.bottom.equalToSuperview().offset(-16)
            
            if showBellButton {
                $0.trailing.equalTo(bellButton.snp.leading).offset(-12)
            } else {
                $0.trailing.equalToSuperview().offset(-20)
            }
        }
    }
}
