import Foundation
import CoreData


final class CoreDataStack {
    
    
    static let store = CoreDataStack()
    private init() {}
    
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    var fetchedBookmarks = [Bookmark]()
    
    func storeBookmark(withTitle title: String, withURL url: URL) {
        let bookmark = Bookmark(context: context)
        bookmark.title = title
        bookmark.url = url
        try! context.save()
    }

    func fetchBookmarks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        self.fetchedBookmarks = try! context.fetch(fetchRequest) as! [Bookmark]
    }
    
    func delete(bookmark: Bookmark) {
        context.delete(bookmark)
        try! context.save()
    }
    
    
    lazy var persistentContainer: CustomPersistantContainer = {
        
        let container = CustomPersistantContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
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
}


class CustomPersistantContainer : NSPersistentContainer {
    
    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.net.shanehudson.ARBookmarks.bookmarks")!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}
