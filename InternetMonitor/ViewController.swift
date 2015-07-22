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
    dynamic var icon : NSImage? = nil
    dynamic var readableError : NSString? = nil
}

class ViewController: NSViewController {

    let queue = NSOperationQueue()
    var timer : NSTimer? = nil
    var dateFormat = NSDateFormatter()
    
    @IBOutlet var arrayController: NSArrayController!
    
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
        
        var dict = IMRequest()
        dict.timestamp = NSDate()
        dict.loading = true
        self.arrayController.addObject(dict)

        let url = NSURL(string: "http://speedtest.wdc01.softlayer.com/downloads/test10.zip")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                let date = NSDate()
                let dateString = self.dateFormat.stringFromDate(date)
                
                if let err = error {
                    print("\(dateString): error: \(error.localizedDescription)\n")
                    
                    dict.icon = NSImage(named: "NSStatusUnavailable")
                    dict.readableError = error.localizedDescription
                    
                } else if let htmlResponse = response as? NSHTTPURLResponse {
                    
                    if htmlResponse.statusCode != 200 {
                        print("\(dateString): status: \(htmlResponse.statusCode)\n")
                        
                        dict.icon = NSImage(named: "NSStatusUnavailable")
                        dict.readableError = "Status: \(htmlResponse.statusCode)"
                        self.arrayController.addObject(dict)
                    } else {
                        dict.icon = NSImage(named: "NSStatusAvailable")
                        print("\(dateString): ok\n")
                    }
                    
                } else {
                    dict.icon = NSImage(named: "NSStatusAvailable")
                    print("\(dateString): ok\n")
                }
                
                dict.loading = false

                self.reschedule()
                
            })
        }
    
    }
    
    func reschedule() {
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
        
    }

}

