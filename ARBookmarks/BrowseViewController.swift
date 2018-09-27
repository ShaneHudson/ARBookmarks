//
//  BrowseViewController.swift
//  ARBookmarks
//
//  Created by Shane Hudson on 25/09/2018.
//  Copyright © 2018 Shane Hudson. All rights reserved.
//

import UIKit
import ARKit

class BrowseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let store = CoreDataStack.store
    let cellReuseIdentifier = "cell"
    
    var transform:matrix_float4x4? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.fetchBookmarks()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.fetchedBookmarks.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = store.fetchedBookmarks[indexPath.row].url?.absoluteString
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let anchor = URLAnchor(transform: (transform)!)
        anchor.url = store.fetchedBookmarks[indexPath.row].url
        
        self.performSegue(withIdentifier: "unwindBrowse", sender: anchor)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID! == "unwindBrowse") {
            let yourVC:ViewController = segue.destination as! ViewController
            yourVC.selected = sender as? URLAnchor
        }
    }
}
