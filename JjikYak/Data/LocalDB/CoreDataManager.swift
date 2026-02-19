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
    
}
