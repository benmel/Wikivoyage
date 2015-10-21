//
//  NavigationTitle.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/20/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class NavigationTitle {
    
    private static let font = UIFont(name: "Lobster1.4", size: 22)
    private static let textColor = UIColor.whiteColor()
    private static let text = "Voyageur"
    private static let height: CGFloat = 44
    
    static func getTitleView() -> UIView {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.text = text
        label.sizeToFit()
        
        let view = UIView()
        view.frame.size = CGSize(width: label.frame.width, height: height)
        label.center = view.center
        view.addSubview(label)
        
        return view
    }
}
