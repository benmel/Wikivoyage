//
//  MainViewController+UITableViewDataSource.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/6/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import SDWebImage

extension MainViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTableViewCell
        let searchResult = searchResults[indexPath.row]
        
        cell.accessoryType = .DisclosureIndicator
        cell.title.text = searchResult.pageTitle
        
        // If there's a thumbnail URL set URL, otherwise it's nil
        let url = (searchResult.thumbnailURL != nil) ? NSURL(string: searchResult.thumbnailURL!) : nil
        cell.thumbnail.sd_setImageWithURL(url, placeholderImage: placeholder)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.isEmpty {
            tableView.separatorStyle = .None
        } else {
            tableView.separatorStyle = .SingleLine
        }
        
        return searchResults.count
    }
}