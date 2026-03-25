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
    private let customNavBar = CustomNavigationBar()
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
        
        customNavBar.configure(
            title: "새로운 약 등록",
            subTitle: nil,
            showBackButton: true,
            showBellButton: false
        )
        
        configure()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        
        quickAddButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                print("빠른 등록 클릭됨 - 카메라/앨범 화면으로 이동")
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
}
