//
//  Scene.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import SpriteKit
import ARKit
import CoreData

class Scene: SKScene {
    var sight: SKSpriteNode!
    let store = CoreDataStack.store
    
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

        let location = sight.position
        
        // Get all objects hit by touch, ignore the first as that is the crosshair
        let targets = nodes(at: location).dropFirst()
        
        if (targets.count > 0) {
            let target = targets.first as! SKLabelNode
            let url = target.name!
            promptOpenURL(url: url, node: target)
        } else {
            
            if let currentFrame = sceneView.session.currentFrame {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.8
                let transform = simd_mul(currentFrame.camera.transform, translation)

                promptForURL(transform: transform)
            }
        }
    }
    
    func promptOpenURL(url: String, node: SKLabelNode) {
        print("Input: Opening URL " + url)
        let ac = UIAlertController(title: url, message: "Do you want to open this URL in Safari?", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Open", style: .default) { (action) -> Void in
            UIApplication.shared.open(URL(string: url)!, options: [:])
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Input: Opening URL cancelled")
        }

        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) -> Void in
            node.removeFromParent()
        }
        
        ac.addAction(submitAction)
        ac.addAction(removeAction)
        ac.addAction(cancelAction)
        view?.window?.rootViewController?.present(ac, animated: true)
    }
    
    func promptForURL(transform: matrix_float4x4) {
        let ac = UIAlertController(title: "Place bookmark", message: nil, preferredStyle: .alert)
        
        let enterAction = UIAlertAction(title: "Enter URL", style: .default) { (action) -> Void in
            self.promptEnterURL(transform: transform)
        }
        
        let chooseAction = UIAlertAction(title: "Choose existing", style: .default) { (action) -> Void in
            self.promptChooseURL(transform: transform)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Input: Adding URL cancelled")
        }
        
        ac.addAction(enterAction)
        ac.addAction(chooseAction)
        ac.addAction(cancelAction)
        view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
    
    func promptEnterURL(transform: matrix_float4x4) {
        let ac = UIAlertController(title: "Enter URL", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) in
            textField.keyboardType = UIKeyboardType.URL
        })
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            if (answer.text != "") {
                print("Input: Adding URL " + answer.text!)
                self.addAnchor(url: URL(string: answer.text!)!, transform: transform)
            }
        }
        
        let backAction = UIAlertAction(title: "Back", style: .cancel) { _ in
            self.promptForURL(transform: transform)
        }
        
        ac.addAction(submitAction)
        ac.addAction(backAction)
        view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
    
    func promptChooseURL(transform: matrix_float4x4) {
        self.store.fetchBookmarks()
        let vc = view?.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SecondView") as? BrowseViewController
        view?.window?.rootViewController?.navigationController?.pushViewController(vc!, animated: true)
        view?.window?.rootViewController?.performSegue(withIdentifier: "browse", sender: transform)
    }
    
    func addAnchor(url: URL, transform: matrix_float4x4) {
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        // Create anchor using the given current position
        let anchor = URLAnchor(transform: transform)
        anchor.url = url
        sceneView.session.add(anchor: anchor)
    }
}
