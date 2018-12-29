//
//  ViewController.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 13/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import FavIcon
import Fabric
import Crashlytics

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let store = CoreDataStack.store
    var selected:URLAnchor? = nil
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        print("got to unwind " + (selected?.url?.absoluteString)!)
        store.getCount()
        Answers.logCustomEvent(withName: "Placed Bookmark", customAttributes: [
            "Total bookmarks": store.totalBookmarks,
            "Placed bookmarks": store.placedBookmarks,
            "Unplaced bookmarks": store.unplacedBookmarks,
        ] )

        sceneView.session.add(anchor: (selected)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.isHidden = true
        store.fetchNonPlacedBookmarks()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
//        sceneView.showsFPS = true
//        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
//        let labelNode = SKLabelNode(text: "🔗")
//        labelNode.horizontalAlignmentMode = .center
//        labelNode.verticalAlignmentMode = .center
        let labelNode:SKSpriteNode = SKSpriteNode()
        var url:String = ""
        
        if let urlanchor = anchor as? URLAnchor {
            url = (urlanchor.url?.absoluteString)!
            labelNode.name = url
        }
        
        do {
            try FavIcon.downloadPreferred(url, width: 200, height: 200, completion: { (result) in
                if case let .success(image) = result {
                    let Texture = SKTexture(image: image)
                    
                    labelNode.texture = Texture
                    labelNode.size = CGSize(width: 50, height: 50)
                } else if case let .failure(error) = result {
                    print("failed to download preferred favicon for \(url): \(error)")
                }
            })
        } catch let error {
            print("failed to download preferred favicon for \(url): \(error)")
        }
        
        return labelNode
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        errorLabel.text = "Session failed: \(error.localizedDescription)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
