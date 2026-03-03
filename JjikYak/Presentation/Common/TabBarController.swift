//
//  TabBarController.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    private let addPillButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.systemBlue
        button.setImage(UIImage(systemName: "pill.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 35
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        setValue(CustomTabBar(), forKey: "tabBar")
        configureTabBar()
        setUp()
        setupAddPillButton()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let buttonSize: CGFloat = 70
        addPillButton.frame = CGRect(
            x: (view.bounds.width - buttonSize) / 2,
            y: view.bounds.height - 140, // 탭 바 높이와 Safe Area를 고려해 조정
            width: buttonSize,
            height: buttonSize
        )
    }
    
    private func setupAddPillButton() {
        view.addSubview(addPillButton)
    }
    
    private func bind() {
        addPillButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentAddPillViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func presentAddPillViewController() {
        let addPillVC = AddPillViewController()
        addPillVC.view.backgroundColor = .white
        
        let nav = UINavigationController(rootViewController: addPillVC)
        nav.modalPresentationStyle = .fullScreen
        
        addPillVC.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close)
        addPillVC.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak addPillVC] in
                addPillVC?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.present(nav, animated: true)
    }
    
    private func configureTabBar() {
        let toDayDoseVC = TodayDoseViewController()
        let historyVC = HistoryViewController()
        let todayNav = UINavigationController(rootViewController: toDayDoseVC)
        let historyNav = UINavigationController(rootViewController: historyVC)
        toDayDoseVC.tabBarItem = UITabBarItem(
            title: "오늘",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        historyVC.tabBarItem = UITabBarItem(
            title: "히스토리",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        
        viewControllers = [todayNav, historyNav]
    }
    private func setUp() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    class CustomTabBar: UITabBar {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = 100
            return sizeThatFits
        }
    }
}
