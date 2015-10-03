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

    var title: UILabel = UILabel.newAutoLayoutView()
    var thumbnail: UIImageView = UIImageView.newAutoLayoutView()
    var didSetupConstraints = false
    
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
        self.accessoryType = .DisclosureIndicator
        
        contentView.addSubview(title)
        contentView.addSubview(thumbnail)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            title.autoPinEdgeToSuperviewEdge(.Top)
            title.autoPinEdgeToSuperviewEdge(.Bottom)
            title.autoPinEdgeToSuperviewEdge(.Trailing)
            title.autoPinEdge(.Leading, toEdge: .Trailing, ofView: thumbnail, withOffset: 20)
            
            thumbnail.autoPinEdgeToSuperviewEdge(.Top)
            thumbnail.autoPinEdgeToSuperviewEdge(.Bottom)
            thumbnail.autoPinEdgeToSuperviewEdge(.Leading)
            thumbnail.autoSetDimension(.Width, toSize: 60)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
