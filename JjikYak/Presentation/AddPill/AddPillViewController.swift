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

class AddPillViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let quickAddButton = AddMethodCardView(type: .quick)
    private let directAddButton = AddMethodCardView(type: .direct)
    
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
        
        configure()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        if let backButton = setNavigationTitle(main: "약 등록 방법 선택", showBackButton: true) {
            backButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.dismiss(animated: true)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func configure() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(quickAddButton)
        stackView.addArrangedSubview(directAddButton)
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
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
        quickAddButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                print("빠른 등록 클릭됨 - 카메라/앨범 화면으로 이동")
            })
            .disposed(by: disposeBag)
        directAddButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                print("수동 등록 클릭됨 - 직접 입력 화면으로 이동")
            })
            .disposed(by: disposeBag)
    }
}
