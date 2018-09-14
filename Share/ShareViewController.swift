//
//  ShareViewController.swift
//  Share
//
//  Created by Shane Hudson on 14/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first as? NSItemProvider {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            print("Sharing url " + shareURL.absoluteString!)
                        }
                        self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                    })
                }
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
