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
                        searchBar.alpha = self.searchBarEndingAlpha
                        self.resultsTable.alpha = self.tableEndingAlpha
                        self.searchButton.alpha = self.searchButtonEndingAlpha
                        self.searchButton.layer.cornerRadius = self.allButtonEndingCornerRadius
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
                    searchBar.alpha = self.searchBarStartingAlpha
                    self.resultsTable.alpha = self.tableStartingAlpha
                    self.searchButton.alpha = self.searchButtonStartingAlpha
                    self.searchButton.layer.cornerRadius = self.allButtonStartingCornerRadius
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
            searchBar.alpha = searchBarStartingAlpha
            resultsTable.alpha = tableStartingAlpha
            searchButton.alpha = searchButtonStartingAlpha
            searchButton.layer.cornerRadius = allButtonStartingCornerRadius
        }
    }
    
    func resetSearchBar(searchBar: UISearchBar, animated: Bool) {
        searchBar.text = ""
        dismissSearchBar(searchBar, animated: animated)
        searchResults.removeAll()
        resultsTable.reloadData()
    }
}
