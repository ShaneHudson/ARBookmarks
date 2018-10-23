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
    var refreshControl: UIRefreshControl!
    
    let store = CoreDataStack.store
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var segmentToggle: UISegmentedControl!
    
    @IBAction func SegmentedControllButtonClickAction(_ sender: UISegmentedControl) {
        self.fetchBookmarks()
    }
    
    var transform:matrix_float4x4? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchBookmarks()
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func fetchBookmarks() {
        if (segmentToggle.selectedSegmentIndex == 0) {
            self.store.fetchNonPlacedBookmarks()
        }
        else {
            self.store.fetchPlacedBookmarks()
        }
        self.tableView.reloadData()
    }
    
    
    @objc func refresh(_ sender: Any) {
        self.fetchBookmarks()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.isHidden = false
        self.fetchBookmarks()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.navigationBar.isHidden = true
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            self.store.delete(bookmark: self.store.fetchedBookmarks[indexPath.row])
            self.fetchBookmarks()
        }
        return [delete]
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (transform != nil && store.fetchedBookmarks[indexPath.row].url != nil) {
            let anchor = URLAnchor(transform: (transform)!)
            let bookmark = store.fetchedBookmarks[indexPath.row]
            anchor.url = bookmark.url
            if (segmentToggle.selectedSegmentIndex == 0) {
                // This makes sure it only moves from unplaced to placed if unplaced to begin with
                self.store.delete(bookmark: bookmark)
                self.store.storeBookmark(withTitle: "Bookmark store", withURL: (anchor.url?.absoluteURL)!, isPlaced: true)
            }
            self.performSegue(withIdentifier: "unwindBrowse", sender: anchor)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID! == "unwindBrowse") {
            let yourVC:ViewController = segue.destination as! ViewController
            yourVC.selected = sender as? URLAnchor
        }
    }
}
