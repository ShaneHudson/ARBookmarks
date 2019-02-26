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
import Fabric
import Crashlytics

class Scene: SKScene {
    var sight: SKNode!
    let store = CoreDataStack.store
    var viewController: ViewController!
    override func sceneDidLoad() {
        sight = SKSpriteNode(imageNamed: "sight")
        addChild(sight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let targets = self.getTargets()
        
        if (targets.count > 0) {
            viewController.setTarget(newTarget: targets[0].name!)
        }
        else {
            viewController.setTarget(newTarget: "")
        }
    }
    
    public func getTargets() -> [SKNode] {
        let location = sight.position
        
        // Get all objects hit by touch, ignore the first as that is the crosshair
        let targets = nodes(at: location).dropFirst()
        if (targets.count > 0) {
            return Array(targets)
        }
        return []
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        let location = sight.position
        
        // Get all objects hit by touch, ignore the first as that is the crosshair
        let targets = nodes(at: location).dropFirst()
        
        if (targets.count > 0) {
            let target = targets.first
            let url = target!.name!
            promptOpenURL(url: url, node: target!)
        } else {
            
            if let currentFrame = sceneView.session.currentFrame {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.3
                let transform = simd_mul(currentFrame.camera.transform, translation)

                promptForURL(transform: transform)
            }
        }
    }
    
    func promptOpenURL(url: String, node: SKNode) {
        print("Input: Opening URL " + url)
        let ac = UIAlertController(title: url, message: "Do you want to open this URL in Safari?", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Open", style: .default) { (action) -> Void in
            var urlstring = url
            if (URL(string: url)?.host == nil) {
                urlstring = "https://\(url)"
            }
            UIApplication.shared.open(URL(string: urlstring)!, options: [:])
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Input: Opening URL cancelled")
        }

        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) -> Void in
            self.store.getCount()
            Answers.logCustomEvent(withName: "Unplaced Bookmark", customAttributes: [
                "Total bookmarks": self.store.totalBookmarks,
                "Placed bookmarks": self.store.placedBookmarks,
                "Unplaced bookmarks": self.store.unplacedBookmarks,
            ] )
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
        self.store.fetchNonPlacedBookmarks()
        view?.window?.rootViewController?.performSegue(withIdentifier: "browse", sender: transform)
    }
    
    func addAnchor(url: URL, transform: matrix_float4x4) {
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        // Create anchor using the given current position
        let anchor = URLAnchor(transform: transform)
        anchor.url = url
        
        self.store.storeBookmark(withTitle: "Bookmark store", withURL: url.absoluteURL, isPlaced: true)
        
        self.store.getCount()
        Answers.logCustomEvent(withName: "Placed Bookmark", customAttributes: [
            "Total bookmarks": store.totalBookmarks,
            "Placed bookmarks": store.placedBookmarks,
            "Unplaced bookmarks": store.unplacedBookmarks,
        ] )

        sceneView.session.add(anchor: anchor as! URLAnchor)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor as! URLAnchor, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        self.viewController.multipeerSession.sendToAllPeers(data)
        
        if #available(iOS 12.0, *) {
            self.Save()
        }
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
    func Save() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        sceneView.session.getCurrentWorldMap { worldMap, error in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap!, requiringSecureCoding: true)
                print("Save: ", data)
                try data.write(to: self.mapSaveURL, options: [.atomic])
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }

}
