//
//  Extensions.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit

extension UIViewController {
    func setNavigationTitle(main: String, sub: String? = nil) {
        // 내비게이션 바 배경색 및 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        
        // 내비게이션 바 아이템(뒤로가기 버튼 등) 색상을 흰색으로
        navigationController?.navigationBar.tintColor = .white
        
        // 실제 적용
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 커스텀 타이틀 뷰 설정
        let titleView = CustomTitleView()
        titleView.updateTitle(main: main, sub: sub)
        
        titleView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(50)
        }
        
        self.navigationItem.titleView = titleView
    }
}
