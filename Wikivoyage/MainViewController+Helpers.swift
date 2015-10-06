//
//  MainViewController+Helpers.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/6/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

extension MainViewController {
    func dismissKeyboard() {
        locationSearchBar.resignFirstResponder()
        // Test if cancel button is needed
        // enableCancelButton(locationSearchBar)
    }
    
    // Prevent cancel button from being disabled automatically
    func enableCancelButton(searchBar: UISearchBar) {
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKindOfClass(UIButton) {
                    let button = subview as! UIButton
                    button.enabled = true
                    return
                }
            }
        }
    }
    
    func showSearchBar(searchBar: UISearchBar) {
        searchBarTop = true
        
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.5,
            animations: {
                self.view.layoutIfNeeded()
            }, completion: { finished in
                UIView.animateWithDuration(0.2,
                    animations: {
                        searchBar.alpha = 1
                        self.resultsTable.alpha = 1
                        self.searchButton.alpha = 0
                    }, completion: { finished in
                        searchBar.becomeFirstResponder()
                    }
                )
            }
        )
    }
    
    func dismissSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBarTop = false
        searchBar.resignFirstResponder()
        
        if animated {
            UIView.animateWithDuration(0.2,
                animations: {
                    searchBar.alpha = 0
                    self.resultsTable.alpha = 0
                    self.searchButton.alpha = 1
                }, completion:  { finished in
                    self.view.setNeedsUpdateConstraints()
                    self.view.updateConstraintsIfNeeded()
                    UIView.animateWithDuration(0.5,
                        animations: {
                            self.view.layoutIfNeeded()
                        }
                    )
                }
            )
        } else {
            view.setNeedsUpdateConstraints()
            view.updateConstraintsIfNeeded()
            view.layoutIfNeeded()
            searchBar.alpha = 0
            resultsTable.alpha = 0
            searchButton.alpha = 1
        }
    }
    
    func resetSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBar.text = ""
        dismissSearchBar(searchBar, animated: animated)
        searchResults.removeAll()
        resultsTable.reloadData()
    }
}
