//
//  ViewController.swift
//  InternetMonitor
//
//  Created by Christian Beer on 22.07.15.
//  Copyright (c) 2015 Christian Beer. All rights reserved.
//

import Cocoa

class IMRequest: NSObject {
    dynamic var timestamp : NSDate? = nil
    dynamic var loading : Bool = false
    dynamic var status : NSString? = nil
    dynamic var icon : NSImage? = nil
    dynamic var readableError : NSString? = nil
}

class ViewController: NSViewController, NSTableViewDelegate {

    let queue = NSOperationQueue()
    var timer : NSTimer? = nil
    var dateFormat = NSDateFormatter()
    
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        update()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    func update() {
        
        var req = IMRequest()
        req.timestamp = NSDate()
        req.loading = true
        self.arrayController.addObject(req)

        let url = NSURL(string: "http://speedtest.wdc01.softlayer.com/downloads/test10.zip")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                let date = NSDate()
                let dateString = self.dateFormat.stringFromDate(date)
                
                if let err = error {
                    print("\(dateString): error: \(error.localizedDescription)\n")
                    
                    req.status = "error"
                    req.icon = NSImage(named: "NSStatusUnavailable")
                    req.readableError = error.localizedDescription
                    
                } else if let htmlResponse = response as? NSHTTPURLResponse {
                    
                    if htmlResponse.statusCode != 200 {
                        print("\(dateString): status: \(htmlResponse.statusCode)\n")
                        
                        req.status = "error"
                        req.icon = NSImage(named: "NSStatusUnavailable")
                        req.readableError = "Status: \(htmlResponse.statusCode)"
                        self.arrayController.addObject(req)
                    } else {
                        req.status = "ok"
                        req.icon = NSImage(named: "NSStatusAvailable")
                        print("\(dateString): ok\n")
                    }
                    
                } else {
                    req.status = "ok"
                    req.icon = NSImage(named: "NSStatusAvailable")
                    print("\(dateString): ok\n")
                }
                
                req.loading = false

                self.reschedule()
                
            })
        }
    
    }
    
    func reschedule() {
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
        
    }

    func copy(sender: AnyObject) {
        let selectedObjects = arrayController.selectedObjects as! [IMRequest]
        let pasteboard = NSPasteboard.generalPasteboard()
        
        pasteboard.declareTypes([NSPasteboardTypeString], owner: self)
        
        var itemsString = ""
        for request in selectedObjects {
            let timestamp = dateFormat.stringFromDate(request.timestamp!)
            let status = request.status ?? ""
            let error = request.readableError ?? ""
            itemsString += "\(status)\t\(timestamp)\t\(error)\n"
        }
        
        pasteboard.setString(itemsString, forType: NSPasteboardTypeString)

    }
    
}

