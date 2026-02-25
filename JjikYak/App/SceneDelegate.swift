//
//  SceneDelegate.swift
//  JjikYak
//
//  Created by 김은서 on 2/13/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let tabBar = TabBarController()
        
        print("API키 확인 : \(ConfigManager.geminiAPIKey)")
        
        let testService = GeminiService()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pillInfos):
                    
                    // 이름, 복용법, 효능을 보기 좋게 하나의 문자열로.
                    let allPillDetails = pillInfos.map { pill in
                        "💊 이름: \(pill.pillName) | 🗓️ 복용법: \(pill.dosage) | 🩹 효능: \(pill.efficacy)"
                    }.joined(separator: "\n------------------------------------------------\n")
                    
                    print("✅ 디코딩 성공. 총 \(pillInfos.count)개의 약이 인식되었습니다.")
                    print("------------------------------------------------")
                    print(allPillDetails)
                    print("------------------------------------------------")
                    
                    
                    let resultVC = ScanResultViewController()
                    
                    // 단일 PillInfo 객체를 배열에 감싸서 화면에 전달
                    resultVC.pillList = pillInfos
                    
                    window.rootViewController = resultVC
                    
                case .failure(let error):
                    print("❌ 통신 또는 디코딩 에러 발생: \(error)")
                }
        testService.parsePillInfo(ocrText: "타이레놀 8시간 이알 서방정, 식후 30분 복용, 비타민 A, 비타민D") { result in
            }
        }
        
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataManager.shared.saveContext()
    }
    
    
}

