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
    @IBOutlet weak var resetButton: UIButton!
    
    let debug = true
    
    let store = CoreDataStack.store
    var selected:URLAnchor? = nil
    var scene = SKScene(fileNamed: "Scene") as! Scene
    var hasAppeared:Bool = false
    var fileSize = 0
    var recentState = ""
    
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        if let selectedUnwrapped = selected {
            store.getCount()
            Answers.logCustomEvent(withName: "Placed Bookmark", customAttributes: [
                "Total bookmarks": store.totalBookmarks,
                "Placed bookmarks": store.placedBookmarks,
                "Unplaced bookmarks": store.unplacedBookmarks,
                ] )
            
            sceneView.session.add(anchor: selectedUnwrapped)
            
            if #available(iOS 12.0, *) {
                self.Save()
            }
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        print("App: viewDidLoad")
        errorLabel.isHidden = !debug
        resetButton.isHidden = !debug
        targetView.isHidden = true
        
        super.viewDidLoad()
        self.navigationController!.navigationBar.isHidden = true
        targetView.layer.masksToBounds = true
        targetView.layer.cornerRadius = 5
        
        store.fetchNonPlacedBookmarks()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Load the SKScene from 'Scene.sks'
        sceneView.presentScene(scene)
        scene.viewController = self
        
        checkReset()
        
        if #available(iOS 12.0, *) {
            if (!self.hasAppeared) {
                self.Load()
            }
            else {
                self.hasAppeared = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkReset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 12.0, *) {
            self.Save()
        }
        
        // Pause the view's session
//        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let urlanchor = anchor as! URLAnchor
        
        if (urlanchor.uuid != nil) {
            let bookmark:Bookmark = store.getByID(id: urlanchor.uuid!)
            
            if (bookmark.url != nil) {
                let labelNode = SKSpriteNode()
                let url:String = bookmark.url!.absoluteString
                labelNode.name = bookmark.uuid
                
                do {
                    try FavIcon.downloadPreferred(url, width: 200, height: 200, completion: { (result) in
                        if case let .success(image) = result {
                            let Texture = SKTexture(image: image)
                            labelNode.texture = Texture
                            labelNode.size = CGSize(width: 50, height: 50)
                        } else if case let .failure(error) = result {
                            print("App: failed to download preferred favicon for \(url): \(error)")
                        }
                    })
                } catch let error {
                    print("App: failed to download preferred favicon for \(url): \(error)")
                }
                return labelNode
            }
            else {
                return nil
            }
            
        }
        else {
            return nil
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        errorLabel.text = "Session failed: \(error.localizedDescription)"
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if #available(iOS 12.0, *) {
            updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
        }
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if #available(iOS 12.0, *) {
            updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
        }
    }
    
    @available(iOS 12.0, *)
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch (trackingState, frame.worldMappingStatus) {
            case (.normal, .mapped),
                 (.normal, .extending):
                message = "Okay"
            
            case (.normal, .limited):
                message = frame.worldMappingStatus.description // "Move around to map the environment."
            
            case (.limited(let reason), _):
                switch reason {
                    case .initializing:
                        message = "Initalising"
                    case .relocalizing:
                        message = "Relocalizing"
                    case .excessiveMotion:
                        message = "Too much camera movement"
                    case .insufficientFeatures:
                        message = "Not enough surface detail"
                }
            default:
                message = trackingState.localizedFeedback
        }
        
        errorLabel.text = message + """
        
        Mapping: \(frame.worldMappingStatus.description)
        Tracking: \(frame.camera.trackingState.description)
        File size: \(self.fileSize)
        State: \(self.recentState)
        """
    }
    
    public func setTarget(newTarget:String) {
        targetLabel.text = newTarget
        if (newTarget == "") {
            targetView.isHidden = true
        }
        else { 
            targetView.isHidden = false
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // This Save is to fix a bug where the most recent bookmark never showed on load
        if #available(iOS 12.0, *) {
            Save()
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        checkReset()
    }
    
    // MARK: - Persistence: Saving and Loading
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("arbookmarks")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    @available(iOS 12.0, *)
    func Load() {
        
        /// - Tag: ReadWorldMap
        if ((mapDataFromFile) == nil) {
            recentState = "Failed to load world map"
            print("Failed to load world map")
            self.initWorld()
        }
        else {
            let worldMap: ARWorldMap? = {
                guard let data = mapDataFromFile
                    else {
                        fatalError("Map data should already be verified to exist before Load button is enabled.")
                    }
                print("App: Load: ", data)
                self.fileSize = data.count
                do {
                    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                        else { fatalError("No ARWorldMap in archive.") }
                    
                    recentState = "Loaded world map"
                    print("Loaded world map")
                    return worldMap
                } catch {
                    recentState = "Can't unarchive ARWorldMap"
                    errorLabel.backgroundColor = UIColor.red
                    print("Can't unarchive ARWorldMap from file data: \(error)")
                    return nil
                }
            }()
            
            if (worldMap == nil) {
                recentState = "Failed to load nil world map"
                print("Failed to load nil world map")
                self.initWorld()
            }
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    @available(iOS 12.0, *)
    public func Save() {
        
        sceneView.session.getCurrentWorldMap { worldMap, error in
            
            if (worldMap == nil) {
                print("App: Save error: " + error.debugDescription)
                return
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap!, requiringSecureCoding: true)
                self.fileSize = data.count
                print("App: Save: ", data)
                self.recentState = "Saved"
                try data.write(to: self.mapSaveURL, options: [.atomic])
            } catch {
                print("App: Save failed")
                self.recentState = "Save failed"
                fatalError ("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    func checkReset() {
        let needsReset = UserDefaults.standard.bool(forKey: "reset_world_map")
        if (needsReset) {
            initWorld()
            recentState = "Reset world map via settings"
            UserDefaults.standard.set(false, forKey: "reset_world_map")
        }
    }

    func initWorld() {
        print("App: Init world")
        self.errorLabel.text = "Init world"
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        if #available(iOS 12.0, *) {
            self.Save()
        }
    }
    
    @IBAction func Reset(_ sender: Any) {
        initWorld()
        recentState = "Reset world map via debug button"
    }
}
