//
//  SearchButton.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/20/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class SearchButton: UIButton {
    
    var title = UILabel.newAutoLayoutView()
    var thumbnail = UIImageView.newAutoLayoutView()
    
    private let titleFont = UIFont(name: "Avenir-Medium", size: 20)
    private let thumbnailInset: CGFloat = 15
    private let shadowOpacity: Float = 1
    private let shadowRadius: CGFloat = 0
    private let shadowOffset = CGSize(width: 0, height: 2)
    
    private let mainColor = UIColor(red: 27/255, green: 163/255, blue: 156/255, alpha: 1)
    private let shadowColor = UIColor(red: 22/255, green: 130/255, blue: 125/255, alpha: 1)
    private let initialColor = UIColor.whiteColor()
    private let highlightedColor = UIColor.lightGrayColor()
    
    var didSetupConstraints = false
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                title.textColor = highlightedColor
                thumbnail.tintColor = highlightedColor
            }
            else {
                title.textColor = initialColor
                thumbnail.tintColor = initialColor
            }
        }
    }
    
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
        thumbnail.contentMode = .Center
        thumbnail.tintColor = initialColor
        title.textColor = initialColor
        title.font = titleFont
        
        backgroundColor = mainColor
        layer.shadowColor = shadowColor.CGColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        
        addSubview(thumbnail)
        addSubview(title)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            thumbnail.autoAlignAxisToSuperviewAxis(.Horizontal)
            thumbnail.autoPinEdgeToSuperviewEdge(.Leading, withInset: thumbnailInset)
            title.autoCenterInSuperview()
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
