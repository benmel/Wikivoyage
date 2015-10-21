//
//  MapViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/9/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import MapKit
import PureLayout
import MBProgressHUD

class MapViewController: UIViewController {

    var mapView: MKMapView!
    var coordinate: CLLocationCoordinate2D?
    
    private let span = MKCoordinateSpanMake(0.4, 0.4)
    private let backgroundColor = UIColor.blackColor()
    private let barTitle = "Map"
    private let errorMessage = "Map not available"
    
    var didSetupConstraints = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupMap()
        centerMap()
    }
    
    // MARK: - Initialization
    
    func setupNavBar() {
        title = barTitle
    }
    
    func setupMap() {
        mapView = MKMapView.newAutoLayoutView()
        mapView.backgroundColor = backgroundColor
        view.addSubview(mapView)
    }
    
    func centerMap() {
        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            showAlert(errorMessage)
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            mapView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            mapView.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
            mapView.autoPinEdgeToSuperviewEdge(.Leading)
            mapView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: - Helpers
    
    func showAlert(text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = text
        hud.mode = .Text
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 1)
    }
}
