//
//  Utilities.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 31/12/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import ARKit

@available(iOS 12.0, *)
extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        }
    }
}

extension ARCamera.TrackingState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .notAvailable:
            return "Not Available"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.excessiveMotion):
            return "Excessive Motion"
        case .limited(.insufficientFeatures):
            return "Insufficient Features"
        case .limited(.relocalizing):
            return "Relocalizing"
        }
    }
}

extension ARCamera.TrackingState {
    var localizedFeedback: String {
        switch self {
            case .normal:
                // No planes detected; provide instructions for this app's AR interactions.
                return "Move around to map the environment."
            
            case .notAvailable:
                return "Tracking unavailable."
            
            case .limited(.excessiveMotion):
                return "Move the device more slowly."
            
            case .limited(.insufficientFeatures):
                return "Point the device at an area with visible surface detail, or improve lighting conditions."
                
            case .limited(.relocalizing):
                return "Resuming session — move to where you were when the session was interrupted."
            
            case .limited(.initializing):
                return "Initializing AR session."
        }
    }
}
