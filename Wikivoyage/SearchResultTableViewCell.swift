//
//  SearchResultTableViewCell.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/1/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class SearchResultTableViewCell: UITableViewCell {

    var title = UILabel.newAutoLayoutView()
    var thumbnail = UIImageView.newAutoLayoutView()
    var didSetupConstraints = false
    
    private let thumbnailWidth: CGFloat = 60
    private let thumbnailInset: CGFloat = 2
    private let titleOffset: CGFloat = 20
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        thumbnail.contentMode = .ScaleAspectFill
        thumbnail.clipsToBounds = true
        
        contentView.addSubview(title)
        contentView.addSubview(thumbnail)
        
        accessoryType = .DisclosureIndicator
        separatorInset = UIEdgeInsets(top: 0, left: thumbnailWidth + titleOffset, bottom: 0, right: 0)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            title.autoPinEdgeToSuperviewEdge(.Top)
            title.autoPinEdgeToSuperviewEdge(.Bottom)
            title.autoPinEdgeToSuperviewEdge(.Trailing)
            title.autoPinEdge(.Leading, toEdge: .Trailing, ofView: thumbnail, withOffset: titleOffset)
            
            thumbnail.autoPinEdgeToSuperviewEdge(.Top, withInset: thumbnailInset)
            thumbnail.autoPinEdgeToSuperviewEdge(.Bottom, withInset: thumbnailInset)
            thumbnail.autoPinEdgeToSuperviewEdge(.Leading)
            thumbnail.autoSetDimension(.Width, toSize: thumbnailWidth)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
