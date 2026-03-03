//
//  Extensions.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit
import SnapKit

// 네비게이션바 설정
extension UIViewController {
    
    @discardableResult
    func setNavigationTitle(main: String, sub: String? = nil, showBackButton: Bool = true) -> UIBarButtonItem? {
        
        // 배경 및 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 타이틀 뷰 설정
        let titleView = CustomTitleView()
        titleView.updateTitle(main: main, sub: sub)
        titleView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        let titleItem = UIBarButtonItem(customView: titleView)
        
        // 분기 처리: 버튼이 필요할 때 vs 필요 없을 때
        if showBackButton {
            // 화살표가 필요한 경우
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.left"),
                style: .plain,
                target: nil,
                action: nil
            )
            self.navigationItem.leftBarButtonItems = [backButton, titleItem]
            self.navigationItem.titleView = nil
            
            return backButton
            
        } else {
            // 화살표가 필요 없는 경우 (타이틀만 왼쪽에 덩그러니)
            self.navigationItem.leftBarButtonItems = [titleItem]
            self.navigationItem.titleView = nil
            
            return nil
        }
    }
}

// 취소선 설정
extension String {
    func strikeThrough(color: UIColor) -> NSAttributedString {
        return NSAttributedString(
            string: self,
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: color
            ]
        )
    }
}
