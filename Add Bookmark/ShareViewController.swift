//
//  ShareViewController.swift
//  Add Bookmark
//
//  Created by Shane Hudson on 22/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import UIKit
import Social
import CoreData

class ShareViewController: UIViewController {
    
    let store = CoreDataStack.store
    
    override func viewDidLoad() {
        
        let ac = UIAlertController(title: "Save to AR Bookmarks?", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            self.didSelectPost()
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
        }
        
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
        self.present(ac, animated: true)
    }
    
    func didSelectPost() {
        if let item = self.extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
                            if let shareURL = url as? NSURL {
                                self.store.storeBookmark(withTitle: "Bookmark store", withURL: shareURL.absoluteURL!, isPlaced: false)
                                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                            }
                        })
                    }
                }
            }
        }
    }
}
