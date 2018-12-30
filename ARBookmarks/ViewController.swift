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
        let urlanchor = anchor as! URLAnchor
        
        if (urlanchor.url != nil) {
            let labelNode = SKSpriteNode()
            var url:String = ""
            
            url = (urlanchor.url?.absoluteString)!
            labelNode.name = url
            
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
        } else {
            let labelNode = SKLabelNode(text: "🔗")
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            labelNode.name = "https://example.com"
            return labelNode
        }
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
    
    // MARK: - Persistence: Saving and Loading
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    @available(iOS 12.0, *)
    @IBAction func Load(_ sender: Any) {
        /// - Tag: ReadWorldMap
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromFile
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            print("Load: ", data)
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        
        worldMap.anchors.forEach { (anchor) in
            print(anchor)
//            sceneView.session.add(anchor: anchor)
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @available(iOS 12.0, *)
    @IBAction func Save(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                print("Save: ", data)
                try data.write(to: self.mapSaveURL, options: [.atomic])
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
}
