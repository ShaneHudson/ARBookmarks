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
    var cancelled = false
    var complete = false
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var actionLabel: UIButton!
    
    func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    @IBAction func button(_ sender: UIButton) {
        if (complete == false) {
            cancelled = true
            self.statusLabel.text = "Cancelled"
            self.actionLabel.isHidden = true
        }
        self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
    }
    
    override func viewDidLoad() {
        didSelectPost()
    }
    
    func didSelectPost() {
        self.statusLabel.text = "Sending to AR Bookmarks"
        self.actionLabel.setTitle("Cancel", for: .normal)
        
        if let item = self.extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
                            if let shareURL = url as? NSURL {
                                if (self.cancelled == false) {
                                    
                                    self.store.storeBookmark(withTitle: "Bookmark store", withURL: shareURL.absoluteURL!, isPlaced: false)
                                    self.statusLabel.text = "Sent to AR Bookmarks"
                                    self.complete = true
                                    self.actionLabel.setTitle("Done", for: .normal)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}
