//
//  InfoViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/15/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class InfoViewController: UIViewController {
    
    var infoView: InfoView!
    var closeButton: UIButton!
    
    private let spacing: CGFloat = 10
    private var didSetupConstraints = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfoView()
        setupButton()
    }
    
    // MARK: - Initialization
    
    func setupInfoView() {
        infoView = InfoView.newAutoLayoutView()
        view.addSubview(infoView)
        
        infoView.setNeedsUpdateConstraints()
    }
    
    func setupButton() {
        closeButton = UIButton.buttonWithType(.Custom) as! UIButton
        closeButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.addTarget(self, action: "closeClicked:", forControlEvents: .TouchUpInside)
        view.addSubview(closeButton)
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            infoView.autoPinEdgesToSuperviewEdges()
            closeButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 2*spacing)
            closeButton.autoPinEdgeToSuperviewEdge(.Right, withInset: spacing)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - User Interaction
    
    func closeClicked(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
