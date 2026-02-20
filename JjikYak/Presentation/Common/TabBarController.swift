//
//  TabBarController.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        setValue(CustomTabBar(), forKey: "tabBar")
        configureTabBar()
        setUp()
    }
    
    private func configureTabBar() {
        let toDayDoseVC = TodayDoseViewController()
        let historyVC = HistoryViewController()
        let todayNav = UINavigationController(rootViewController: toDayDoseVC)
        
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
        
        viewControllers = [toDayDoseVC, historyVC]
    }
    private func setUp() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    class CustomTabBar: UITabBar {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = 100 // 원하는 길이
            return sizeThatFits
        }
    }
}
