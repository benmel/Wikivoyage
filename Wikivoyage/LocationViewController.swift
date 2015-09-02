//
//  LocationViewController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 8/31/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import HTMLReader
import Ono

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pageId: Int!
    var pageTitle: String!
    
    var locationTable: UITableView!
    var tableContent: [String] = []
    var sectionTitles: [String] = []
    var sectionIndices: [Int] = []
    var sectionText = [Int: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = pageTitle
        
        // set up collapsible view
        // set up text views
        // get section titles
        // get section text and fill view
        setupTable()
        getSections()
    }
    
    func setupTable() {
        locationTable = UITableView()
        locationTable.dataSource = self
        locationTable.delegate = self
        locationTable.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        locationTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
        self.view.addSubview(locationTable)
    }
    
    func getSections() {
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: ["action": "parse", "pageid": pageId, "prop": "sections", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let sections = json["parse"]["sections"]
                
                for (index: String, section: JSON) in sections {
                    if section["toclevel"] == 1 {
                        self.sectionTitles.append(section["line"].stringValue)
                        self.sectionIndices.append(section["index"].intValue)
                    }
                }
                
                self.tableContent = self.sectionTitles
                self.getAllSectionText()
            }
            
            self.locationTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    
    func getAllSectionText() {
        for section in sectionIndices {
            getSectionText(section)
        }
    }
    
    func getSectionText(section: Int) {
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: ["action": "parse", "pageid": pageId, "prop": "text", "section": section, "disabletoc": "", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)
                let text = json["parse"]["text"]["*"]
                self.sectionText[section] = text.stringValue
                
//                let text_n = "<div>"+text.stringValue+"</div>"
//                let test = HTMLDocument(string: text_n)
//                let n1 = test.firstNodeMatchingSelector("div")
//                let children = n1?.childElementNodes as! [HTMLElement]
            }
        }
    }
    
    // Table view data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as! UITableViewCell
        cell.textLabel?.text = tableContent[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent.count
    }
    
    // Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change this
        let section = sectionIndices[indexPath.row]
        let text = sectionText[section]
//        tableContent.insert(text!, atIndex: indexPath.row+1)
//        let path = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
//        locationTable.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
