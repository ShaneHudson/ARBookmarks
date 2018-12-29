import Foundation
import CoreData

final class CoreDataStack {
    
    
    static let store = CoreDataStack()
    private init() {}
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var fetchedBookmarks = [Bookmark]()
    var totalBookmarks = 0
    var placedBookmarks = 0
    var unplacedBookmarks = 0
    
    func storeBookmark(withTitle title: String, withURL url: URL, isPlaced: Bool?) {
        let bookmark = Bookmark(context: context)
        bookmark.title = title
        bookmark.url = url
        bookmark.isPlaced = isPlaced ?? false
        
        try! context.save()
    }
    
    func getCount() {
        self.bookmarksCount()
        self.placedBookmarksCount()
        self.unplacedBookmarksCount()
    }
    func bookmarksCount() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        let bookmarks = try! context.fetch(fetchRequest) as! [Bookmark]
        self.totalBookmarks = bookmarks.count
    }
    
    func placedBookmarksCount() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        fetchRequest.predicate = NSPredicate(format: "isPlaced == true")
        let bookmarks = try! context.fetch(fetchRequest) as! [Bookmark]
        self.placedBookmarks = bookmarks.count
    }
    
    func unplacedBookmarksCount() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        fetchRequest.predicate = NSPredicate(format: "isPlaced == false")
        let bookmarks = try! context.fetch(fetchRequest) as! [Bookmark]
        self.unplacedBookmarks = bookmarks.count
    }

    func fetchPlacedBookmarks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        fetchRequest.predicate = NSPredicate(format: "isPlaced == true")
        self.fetchedBookmarks = try! context.fetch(fetchRequest) as! [Bookmark]
    }
    
    func fetchNonPlacedBookmarks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark")
        fetchRequest.predicate = NSPredicate(format: "isPlaced == false")
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
