//
//  BrowseViewController.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 25/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import UIKit
import ARKit

class NavigationController: UINavigationController {
    
    var transform:matrix_float4x4? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier

        if (segueID! == "browse") {
            let vc:BrowseViewController = segue.destination as! BrowseViewController
            vc.transform = sender as? matrix_float4x4
        }
        
    }
}
