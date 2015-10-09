//
//  EmptyBackgroundView.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/8/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class EmptyBackgroundView: UIView {

    var topSpace = UIView.newAutoLayoutView()
    var bottomSpace = UIView.newAutoLayoutView()
    var imageView = UIImageView.newAutoLayoutView()
    var topLabel = UILabel.newAutoLayoutView()
    var bottomLabel = UILabel.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    init(image: UIImage, top: String, bottom: String) {
        super.init(frame: CGRectZero)
        setupViews()
        setupImageView(image)
        setupLabels(top, bottom: bottom)
    }
    
    func setupViews() {
        addSubview(topSpace)
        addSubview(bottomSpace)
        addSubview(imageView)
        addSubview(topLabel)
        addSubview(bottomLabel)
    }
    
    func setupImageView(image: UIImage) {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
    }
    
    func setupLabels(top: String, bottom: String) {
        topLabel.text = top
        topLabel.textColor = .darkGrayColor()
        topLabel.font = UIFont.boldSystemFontOfSize(22)
        
        bottomLabel.text = bottom
        bottomLabel.textColor = .grayColor()
        bottomLabel.font = UIFont.systemFontOfSize(18)
        bottomLabel.numberOfLines = 0
        bottomLabel.textAlignment = .Center
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            topSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            topSpace.autoPinEdgeToSuperviewEdge(.Top)
            bottomSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            bottomSpace.autoPinEdgeToSuperviewEdge(.Bottom)
            topSpace.autoSetDimension(.Height, toSize: 10, relation: .GreaterThanOrEqual)
            topSpace.autoMatchDimension(.Height, toDimension: .Height, ofView: bottomSpace)
            
            imageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topSpace)
            imageView.autoAlignAxisToSuperviewAxis(.Vertical)
            imageView.autoSetDimension(.Height, toSize: 200, relation: .LessThanOrEqual)
            
            topLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            topLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: imageView, withOffset: 10)
            
            bottomLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            bottomLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: topLabel, withOffset: 10)
            bottomLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: bottomSpace)
            bottomLabel.autoSetDimension(.Width, toSize: 300)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }

}
