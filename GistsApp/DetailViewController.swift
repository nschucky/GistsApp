//
//  DetailViewController.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/15/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!


    var gist: Gist? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detailsView = self.tableView {
            detailsView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        automaticallyAdjustsScrollViewInsets = false
    }


}

extension DetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            if let file = gist?.files?[indexPath.row], urlString = file.raw_url, url = NSURL(string: urlString) {
                let safariVC = SFSafariViewController(URL: url)
                safariVC.title = file.filename
                self.navigationController?.pushViewController(safariVC, animated: true)
            }
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return gist?.files?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "About"
        case 1:
            return "Files"
        default:
            return "None"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = gist?.description
            } else if indexPath.row == 1 {
                cell.textLabel?.text = gist?.ownerLogin
            }
        case 1:
            if let file = gist?.files?[indexPath.row] {
                cell.textLabel?.text = file.filename
            }
        default:
            break
        }
        return cell
    }
    
}

