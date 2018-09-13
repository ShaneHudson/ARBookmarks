//
//  Scene.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//
import Foundation
import SpriteKit
import ARKit

class Scene: SKScene {
    var sight: SKSpriteNode!

    override func didMove(to view: SKView) {
        sight = SKSpriteNode(imageNamed: "sight")
        addChild(sight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            let location = sight.position
            let targets = nodes(at: location).dropFirst()
                
            if (targets.count > 0) {
                let target = targets.first as! SKLabelNode
                let url = target.name!
                print("opening url " + url)
                UIApplication.shared.open(URL(string: url)!, options: [:])
            } else {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.8
                let transform = simd_mul(currentFrame.camera.transform, translation)


                // debug code to simulate a website bookmark
                let urls = ["https://shanehudson.net", "https://google.com", "https://twitter.com", "https://wikipedia.org"]
                let randomIndex = Int(arc4random_uniform(UInt32(urls.count)))
                let url = URL(string: urls[randomIndex])
                print("adding url " + (url?.absoluteString)!)
                
                // Add a new anchor to the session
                let anchor = URLAnchor(transform: transform)
                anchor.url = url
                sceneView.session.add(anchor: anchor)
            }
        }
    }
}
