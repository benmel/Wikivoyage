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
        configureCell(cell, searchResult: searchResult)
        return cell
    }
    
    func configureCell(cell: LocationTableViewCell, searchResult: SearchResult) {
        cell.accessoryType = .DisclosureIndicator
        cell.title.text = (searchResult.originalTitle != nil) ? searchResult.originalTitle : searchResult.pageTitle
        
        // If there's a thumbnail URL set URL, otherwise it's nil
        let url = (searchResult.thumbnailURL != nil) ? NSURL(string: searchResult.thumbnailURL!) : nil
        cell.thumbnail.sd_setImageWithURL(url, placeholderImage: Images.mapLocationLargeImage, completed: {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) in
            if image != nil && cacheType == .None {
                cell.thumbnail.alpha = 0
                UIView.animateWithDuration(0.3,
                    animations: {
                        cell.thumbnail.alpha = 1
                    }
                )
            }
        })
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return searchResults.count
    }
}
