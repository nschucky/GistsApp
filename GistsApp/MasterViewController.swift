//
//  MasterViewController.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/15/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit
import PINRemoteImage
import SafariServices

class MasterViewController: UITableViewController, SFSafariViewControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()
    var nextPageURLString: String?
    var isLoading = false
    
    var safariVC: SFSafariViewController?
    
    var dateFormatter = NSDateFormatter()
    
    var imageCache: Dictionary<String, UIImage?> = Dictionary<String, UIImage?>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //loadGists(nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        if (!defaults.boolForKey("loadingOAuthToken")) {
            loadInitialData()
        }
        
    }
    
    func loadInitialData() {
        if (!GitHubAPIManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
        } else {
            GitHubAPIManager.sharedInstance.printMyStarredGistsWithOAuth2()
        }
    }
    
    func showOAuthLoginView() {
        let mainSb = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = mainSb.instantiateViewControllerWithIdentifier("LoginVC") as? LoginViewController {
            loginVC.delegate = self
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Not Implemented", message: "Can't create new gists yet, will implement later", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
            
            self.dateFormatter.dateStyle = .ShortStyle
            self.dateFormatter.timeStyle = .LongStyle
            
        }
        super.viewWillAppear(animated)
    }
    
    func refresh(sender: AnyObject) {
        nextPageURLString = nil
        loadGists(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadGists(urlToLoad: String?) {
        isLoading = true
        GitHubAPIManager.sharedInstance.getPublicGists(urlToLoad) { (result, nextPage) in
            self.isLoading = false
            self.nextPageURLString = nextPage
            
            if self.refreshControl != nil && self.refreshControl!.refreshing {
                self.refreshControl?.endRefreshing()
            }
            guard result.error == nil else {
                print(result.error)
                return
            }
            if let fetchedGists = result.value {
                if self.nextPageURLString != nil {
                    self.gists += fetchedGists
                } else {
                    self.gists = fetchedGists
                }
            }
            let now = NSDate()
            let updateString = "Last updated at " + self.dateFormatter.stringFromDate(now)
            self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
            self.tableView.reloadData()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = gists[indexPath.row]
                if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
                    detailViewController.detailItem = object
                    detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    detailViewController.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let gist = gists[indexPath.row]
        cell.textLabel!.text = gist.description
        cell.detailTextLabel?.text = gist.id
        cell.imageView?.image = nil
        cell.imageView?.layer.cornerRadius = 20 
        cell.imageView?.clipsToBounds = true
        
        if let urlString = gist.ownerAvatarURL, url = NSURL(string: urlString) {
            cell.imageView?.pin_setImageFromURL(url, placeholderImage: UIImage(named: "placeholder.png"))
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }
        
        let rowToLoadFromBottom = 5
        let rowsLoaded = gists.count
        if let nextPage = nextPageURLString {
            if (!isLoading && (indexPath.row >= (rowsLoaded - rowToLoadFromBottom))) {
                self.loadGists(nextPage)
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            gists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}


extension MasterViewController: LoginViewDelegate {
    
    
    func didTapLoginButton() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "loadingOAuthToken")
        
        self.dismissViewControllerAnimated(false, completion: nil)
        if let authURL = GitHubAPIManager.sharedInstance.URLToStartOAuth2Login() {
            safariVC = SFSafariViewController(URL: authURL)
            safariVC?.delegate = self
            if let webViewController = safariVC {
                self.presentViewController(webViewController, animated: true, completion: nil)
            }
        }
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad
        didLoadSuccessfully: Bool) {
        // Detect not being able to load the OAuth URL
        if (!didLoadSuccessfully) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "loadingOAuthToken")
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
