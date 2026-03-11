import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JjikYak")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - CREATE (저장)
    // 저장
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - READ (불러오기)
    // 모든 약 불러오기
    func fetchAllPills() -> [Pill] {
        let request: NSFetchRequest<Pill> = Pill.fetchRequest()
        let sort = NSSortDescriptor(key: "alarmTime", ascending: true)
        request.sortDescriptors = [sort]
        
        return(try? context.fetch(request)) ?? []
    }
    // 특정 날짜 약만 불러오기
    func fetchPills(on date: Date) -> [Pill] {
        let request: NSFetchRequest<Pill> = Pill.fetchRequest()
        
        // 날짜 범위 설정 (00:00:00 ~ 23:59:59)
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return [] }
        
        // 조건(Predicate): 알림 시간이 오늘 하루 안에 있는 것들
        let predicate = NSPredicate(format: "alarmTime >= %@ AND alarmTime < %@", startDate as NSDate, endDate as NSDate)
        
        request.predicate = predicate
        // 아침-> 점심-> 저녁 순
        request.sortDescriptors = [NSSortDescriptor(key: "alarmTime", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ 날짜별 데이터 로드 실패: \(error)")
            return []
        }
    }
    
    // MARK: - UPDATE (수정)
    // 약 복용 완료(Check) 상태 변경
    func updatePillStatus(pill: Pill, isTaken: Bool) {
        pill.isTaken = isTaken
        saveContext()
    }
    
    // MARK: - DELETE (삭제)
    //삭제
    func deletePill(_ pill: Pill) {
        context.delete(pill)
        saveContext()
    }
    
    // 현재 시간으로부터 딱 1분 뒤에 울리는 더미 약 추가
    func addTestPillForOneMinuteLater() {
        let pill = Pill(context: context)
        pill.id = UUID()
        pill.title = "1분 뒤 테스트 약"
        pill.memo = "푸시 알림이 잘 오는지 테스트합니다."
        pill.dosage = "1정"
        pill.isTaken = false
        
        // 현재 시간(Date())에서 60초(1분)를 더한 시간으로 설정
        let targetTime = Date().addingTimeInterval(60)
        pill.alarmTime = targetTime
        pill.createdAt = Date() // 생성일은 현재로
        
        saveContext()
        print("✅ 1분 뒤 알림 테스트용 약이 코어데이터에 저장되었습니다: \(targetTime)")
    }
    
    func insertDummyPillsIfNeeded() {
        let request: NSFetchRequest<Pill> = Pill.fetchRequest()
        
        // 필요 시 주석을 해제하여 데이터가 중복 생성되는 것을 방지하세요.
        if let count = try? context.count(for: request), count > 0 {
            print("이미 데이터 있음:", count)
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        // 지정한 날짜(offset)와 시간으로 Date를 만들어주는 헬퍼 함수
        func date(offsetDays: Int, hour: Int, minute: Int) -> Date {
            let targetDay = calendar.date(byAdding: .day, value: offsetDays, to: today) ?? today
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: targetDay) ?? targetDay
        }
        
        // (약 이름, 메모, 용량, 복용여부, 알람시간)
        let dummyData = [
            // 🟢 [과거: 2일 전] 복용 완료 테스트 (모두 true)
            ("오메가3", "혈행 개선", "1캡슐", true, date(offsetDays: -2, hour: 8, minute: 0)),
            ("비타민D", "뼈 건강", "1정", true, date(offsetDays: -2, hour: 13, minute: 0)),
            
            // 🟠 [과거: 1일 전] 복용 미완료 테스트 (일부만 true)
            ("타이레놀", "두통 완화", "500mg", true, date(offsetDays: -1, hour: 9, minute: 0)),
            ("유산균", "장 건강", "1포", false, date(offsetDays: -1, hour: 20, minute: 0)),
            
            // 🟡 [오늘] 현재 상태 테스트 (섞여 있음)
            ("타이레놀", "두통 완화", "500mg", true, date(offsetDays: 0, hour: 8, minute: 0)),
            ("비타민C", "면역력 강화", "1000mg", false, date(offsetDays: 0, hour: 13, minute: 0)),
            ("유산균", "장 건강", "1포", false, date(offsetDays: 0, hour: 20, minute: 30)),
            
            // 🔵 [미래: 내일] 복용 예정 테스트 (미래니까 모두 false)
            ("루테인", "눈 건강", "1캡슐", false, date(offsetDays: 1, hour: 8, minute: 0)),
            ("마그네슘", "근육 이완", "1정", false, date(offsetDays: 1, hour: 19, minute: 0)),
            
            // 🔵 [미래: 3일 뒤] 복용 예정 테스트 2
            ("철분제", "빈혈 예방", "1정", false, date(offsetDays: 3, hour: 10, minute: 0))
        ]
        
        for data in dummyData {
            let pill = Pill(context: context)
            pill.id = UUID()
            pill.title = data.0
            pill.memo = data.1
            pill.dosage = data.2
            pill.isTaken = data.3
            pill.alarmTime = data.4
            
            // 약이 만들어진 날짜(createdAt)도 alarmTime과 동일한 날짜로 맞춰주면 관리가 편합니다.
            pill.createdAt = data.4
            pill.imagePath = nil
            
            print("저장할 alarmTime:", data.4)
        }
        
        saveContext()
    }
}
