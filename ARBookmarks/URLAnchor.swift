//
//  URLAnchor.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//
import ARKit

class URLAnchor: ARAnchor {
    var uuid: String?
    
    override init(transform: matrix_float4x4) {
        super.init(transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.uuid = (anchor as! URLAnchor).uuid
        super.init(anchor: anchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(uuid, forKey: "uuid")
    }

    override class var supportsSecureCoding: Bool { return true }
}
