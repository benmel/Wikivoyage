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

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pageId: Int!
    var pageTitle: String!
    var locationTable: UITableView!
    var sections: [Section] = []
    var tableContent: [TableRow] = []
    var webViews = [Int: WKWebView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = pageTitle
        
        setupTable()
        getSections()
    }
    
    func setupTable() {
        locationTable = UITableView()
        locationTable.dataSource = self
        locationTable.delegate = self
        // Maybe change frame
        locationTable.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        locationTable.registerClass(LocationTableCell.self, forCellReuseIdentifier: "TableCell")
        
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
                        let title = section["line"].stringValue
                        let index = section["index"].intValue
                        let section = Section(title: title, index: index)
                        let tableRow = TableRow(type: "title", sectionTextVisible: false, section: section)
                        self.sections.append(section)
                        self.tableContent.append(tableRow)
                    }
                }
                
                self.getAllSectionText()
            }
            
            self.locationTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func getAllSectionText() {
        for section in sections {
            getSectionText(section)
        }
    }
    
    func getSectionText(section: Section) {
        Alamofire.request(.GET, "https://en.wikivoyage.org/w/api.php", parameters: ["action": "parse", "pageid": pageId, "prop": "text", "section": section.index, "disabletoc": "", "format": "json"]).responseJSON() {
            (_, _, data, error) in
            if(error != nil) {
                NSLog("Error: \(error)")
            } else {
                let json = JSON(data!)["parse"]["text"]["*"]
                section.json = json
            }
        }
    }
    
    func createWebView(section: Section) {
        let doc = HTMLDocument(string: section.json!.stringValue)
        let root = doc.rootElement
        
        removeEditNodes(root)
        removeNodesBeforeAndIncludingH2(root)
        
        section.text = root?.firstNodeMatchingSelector("body")?.innerHTML
        
        let webView = WKWebView(frame: self.view.frame)
        webView.loadHTMLString(section.text!, baseURL: nil)
        self.webViews[section.index] = webView
    }
    
    func removeEditNodes(element: HTMLElement?) {
        if let editNodes = element?.nodesMatchingSelector("[class='mw-editsection']") as? [HTMLElement] {
            for node in editNodes {
                node.removeFromParentNode()
            }
        }
    }
    
    func removeNodesBeforeAndIncludingH2(element: HTMLElement?) {
        if let h2 = element?.firstNodeMatchingSelector("h2"), parent = h2.parentNode {
            let index = Int(parent.indexOfChild(h2))
            if index != NSNotFound {
                for i in 0..<index {
                    parent.mutableChildren.removeObjectAtIndex(i)
                }
            }
        }
    }
    
    // Table view data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let content = tableContent[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! LocationTableCell
        cell.selectionStyle = .None
        cell.clipsToBounds = true
        
        // Use something else instead of string for type
        if content.type == "title" {
            cell.textLabel?.text = content.section.title
        } else if content.type == "text" {
            if cell.webView == nil {
                if webViews[content.section.index] == nil {
                    createWebView(content.section)
                }
                cell.webView = webViews[content.section.index]
                // test for nil
                cell.contentView.addSubview(cell.webView)
            }
        }
    
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent.count
    }
    
    // Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Fixes bug that makes separator line dissapear
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let content = tableContent[indexPath.row]
        if content.type == "title" && content.sectionTextVisible == false {
            content.sectionTextVisible = true
            let newContent = TableRow(type: "text", sectionTextVisible: true, section: content.section)
            tableContent.insert(newContent, atIndex: indexPath.row+1)
            let path = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
            tableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else if content.type == "title" && content.sectionTextVisible == true {
            content.sectionTextVisible = false
            tableContent.removeAtIndex(indexPath.row+1)
            let path = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
            tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
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
