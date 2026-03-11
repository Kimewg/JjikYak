import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // 권한 상태 확인 (비동기로 동작하므로 콜백으로 받습니다)
    func checkNotificationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // 권한 요청
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Pill 배열을 받아 알림 스케줄링
    func scheduleNotifications(for pills: [Pill]) {
        let center = UNUserNotificationCenter.current()
        
        // 중복 방지를 위해 기존 알림 싹 지우기
        center.removeAllPendingNotificationRequests()
        
        for pill in pills {
            guard let time = pill.alarmTime, let title = pill.title else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "찌약 복용 시간"
            content.body = "[\(title)] 드실 시간이에요! 잊지 말고 챙겨 드세요."
            content.sound = .default
            
            // 매일 해당 시간에 울리도록 설정
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            // 알림 고유 ID (나중에 개별 삭제할 때를 대비해 Pill의 ID나 이름을 사용)
            let request = UNNotificationRequest(identifier: "PillNotification_\(title)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("알림 등록 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 모든 알림 끄기
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("모든 푸시 알림이 비활성화 되었습니다.")
    }
}

extension UserDefaults {
    var isNotificationEnabled: Bool {
        get {
            // 저장된 값이 아예 없다면(앱 최초 실행) 기본값을 true로 반환합니다.
            if object(forKey: "isNotificationEnabled") == nil {
                return true
            }
            // 저장된 값이 있다면 그 값을 반환합니다.
            return bool(forKey: "isNotificationEnabled")
        }
        set {
            set(newValue, forKey: "isNotificationEnabled")
        }
    }
}
