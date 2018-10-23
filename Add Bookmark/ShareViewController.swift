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

class ShareViewController: SLComposeServiceViewController {
    
    let store = CoreDataStack.store

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
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

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
