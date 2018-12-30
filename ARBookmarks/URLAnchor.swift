//
//  URLAnchor.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//
import ARKit

open class URLAnchor: ARAnchor {
    var url: URL?
    
    public override init(transform: matrix_float4x4) {
        super.init(transform: transform)
    }
    
    required public init(anchor: ARAnchor) {
        let other = anchor as! URLAnchor
        self.url = other.url
        super.init(anchor: other)
    }
    
    required public init(anchor: URLAnchor) {
        let other = anchor
        self.url = other.url
        super.init(anchor: other)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    override open class var supportsSecureCoding: Bool { return true }
}
