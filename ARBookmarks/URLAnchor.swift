//
//  URLAnchor.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//
import ARKit

class URLAnchor: ARAnchor {
    var url: URL?
    
    override init(transform: matrix_float4x4) {
        super.init(transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.url = (anchor as! URLAnchor).url
        super.init(anchor: anchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let url = aDecoder.decodeObject(forKey: "url") as? URL {
            self.url = url
        } else {
            return nil
        }
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(url, forKey: "url")
    }

    override class var supportsSecureCoding: Bool { return true }
}
