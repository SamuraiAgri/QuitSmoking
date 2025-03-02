import Foundation
import CoreData
import UIKit

class DataStoreService {
    static let shared = DataStoreService()
    
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "QuitSmoking")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // 現在のコンテキストからエンティティを取得するヘルパーメソッド
    func fetchEntities<T: NSManagedObject>(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch \(entityName): \(error)")
            return []
        }
    }
}
