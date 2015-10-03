//
//  WebHeadersTableViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/2/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class WebHeadersTableViewController: UITableViewController {

    var webHeaders = [WebHeader]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return webHeaders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! UITableViewCell
        let webHeader = webHeaders[indexPath.row]
        cell.textLabel?.text = webHeader.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let webHeader = webHeaders[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName("WebHeaderSelected", object: webHeader)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
