import CoreData
import UIKit

final class CoreDataManager {
    
    static let shard = CoreDataManager()
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
        
    func fetchAllPills() -> [Pill] {
        let request: NSFetchRequest<Pill> = Pill.fetchRequest()
        let sort = NSSortDescriptor(key: "alarmTime", ascending: true)
        request.sortDescriptors = [sort]
        
        return(try? context.fetch(request)) ?? []
    }
}
