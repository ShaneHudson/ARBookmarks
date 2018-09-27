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
        super.init(anchor: anchor)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
