//
//  InfoView.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/15/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class InfoView: UIView {
    
    let topSpace = UIView.newAutoLayoutView()
    let bottomSpace = UIView.newAutoLayoutView()
    let imageView = UIImageView.newAutoLayoutView()
    let topLabel = UILabel.newAutoLayoutView()
    let bottomLabel = UILabel.newAutoLayoutView()
    let copyrightLabel = UILabel.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    private let spacing: CGFloat = 10
    private let imageViewHeight: CGFloat = 200
    private let bottomLabelWidth: CGFloat = 350
    private let viewBackgroundColor = UIColor.whiteColor()
    
    private let topFont = UIFont(name: "Lobster1.4", size: 24)
    private let bottomFont = UIFont.systemFontOfSize(16)
    private let copyrightFont = UIFont.systemFontOfSize(14)
    
    private let image = UIImage(named: Images.placeholder)
    private let appName = "Voyageur"
    private let attribution = "All content is available at www.wikivoyage.org.\nContent is available under the Creative Commons Attribution-ShareAlike 3.0 License unless otherwise noted."
    private let copyright = "\u{00A9} 2015 Ben Meline\nwww.benmeline.com"
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        setupMainView()
        setupImageView()
        setupLabels()
    }
    
    func setupMainView() {
        backgroundColor = viewBackgroundColor
        addSubview(topSpace)
        addSubview(bottomSpace)
    }
    
    func setupImageView() {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
    }
    
    func setupLabels() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            topLabel.text = "\(appName) \(version)"
        } else {
            topLabel.text = appName
        }
        topLabel.font = topFont
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .Center
        
        bottomLabel.text = attribution
        bottomLabel.font = bottomFont
        bottomLabel.numberOfLines = 0
        bottomLabel.textAlignment = .Center
        
        copyrightLabel.text = copyright
        copyrightLabel.font = copyrightFont
        copyrightLabel.numberOfLines = 0
        copyrightLabel.textAlignment = .Center
        
        addSubview(topLabel)
        addSubview(bottomLabel)
        addSubview(copyrightLabel)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            topSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            topSpace.autoPinEdgeToSuperviewEdge(.Top)
            bottomSpace.autoAlignAxisToSuperviewAxis(.Vertical)
            bottomSpace.autoPinEdge(.Bottom, toEdge: .Top, ofView: copyrightLabel)
            topSpace.autoSetDimension(.Height, toSize: spacing, relation: .GreaterThanOrEqual)
            topSpace.autoMatchDimension(.Height, toDimension: .Height, ofView: bottomSpace)
            
            imageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topSpace)
            imageView.autoAlignAxisToSuperviewAxis(.Vertical)
            imageView.autoSetDimension(.Height, toSize: imageViewHeight, relation: .LessThanOrEqual)
            
            topLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            topLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: imageView, withOffset: spacing)
            
            bottomLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            bottomLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: topLabel, withOffset: spacing)
            bottomLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: bottomSpace)
            bottomLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0, relation: .GreaterThanOrEqual)
            bottomLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 0, relation: .GreaterThanOrEqual)
            bottomLabel.autoSetDimension(.Width, toSize: bottomLabelWidth, relation: .LessThanOrEqual)
            
            copyrightLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            copyrightLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: spacing)
            
            NSLayoutConstraint.autoSetPriority(1000) {
                self.topLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.bottomLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.copyrightLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            }
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
