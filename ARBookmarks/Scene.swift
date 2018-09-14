//
//  Scene.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

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
        let location = sight.position
        
        // Get all objects hit by touch, ignore the first as that is the crosshair
        let targets = nodes(at: location).dropFirst()
        
        if (targets.count > 0) {
            let target = targets.first as! SKLabelNode
            let url = target.name!
            promptOpenURL(url: url)
        } else {
            promptForURL()
        }
    }
    
    func promptOpenURL(url: String) {
        print("Input: Opening URL " + url)
        let ac = UIAlertController(title: url, message: "Do you want to open this URL in Safari?", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            UIApplication.shared.open(URL(string: url)!, options: [:])
        }

        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            print("Input: Opening URL cancelled")
        }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        view?.window?.rootViewController?.present(ac, animated: true)
    }
    
    func promptForURL() {
        let ac = UIAlertController(title: "Enter URL", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            print("Input: Adding URL " + answer.text!)
            self.addAnchor(url: URL(string: answer.text!)!)
        }
        
        ac.addAction(submitAction)
        view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
    
    func addAnchor(url: URL) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.8
            let transform = simd_mul(currentFrame.camera.transform, translation)


            let anchor = URLAnchor(transform: transform)
            anchor.url = url
            sceneView.session.add(anchor: anchor)

        }
    }
}
