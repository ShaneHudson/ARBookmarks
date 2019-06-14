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
        let cell:UITableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // set the text from the data model
        cell!.textLabel?.text = store.fetchedBookmarks[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            self.store.delete(bookmark: self.store.fetchedBookmarks[indexPath.row])
            self.fetchBookmarks()
        }
        
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { (action, indexPath) in
            
            let ac = UIAlertController(title: "Enter title", message: nil, preferredStyle: .alert)
            ac.addTextField()

            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                let title = ac.textFields![0]
                if (title.text != "") {
                    print("Input: Renaming title to " + title.text!)
                    self.store.rename(bookmark: self.store.fetchedBookmarks[indexPath.row], title: title.text ?? "")
                    self.fetchBookmarks()
                }
            }
            
            ac.addAction(submitAction)
            self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
        }
        
        let open = UITableViewRowAction(style: .normal, title: "Open") { (action, indexPath) in
            UIApplication.shared.open(URL(string: (self.store.fetchedBookmarks[indexPath.row].url?.absoluteString)!)!, options: [:])
        }
        return [delete, rename, open]
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark:Bookmark = store.fetchedBookmarks[indexPath.row] as Bookmark
        if (transform != nil && bookmark.url != nil && bookmark.uuid != nil) {
            let anchor = URLAnchor(transform: (transform)!)
            anchor.uuid = bookmark.uuid
            if (segmentToggle.selectedSegmentIndex == 0) {
                // This makes sure it only moves from unplaced to placed if unplaced to begin with
                self.store.setIsPlaced(bookmark: bookmark, isPlaced: true)
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
