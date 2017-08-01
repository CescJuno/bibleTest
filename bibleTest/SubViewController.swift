//
//  SubViewController.swift
//  bibleTest
//
//  Created by Duranno on 2017. 8. 1..
//  Copyright © 2017년 Duranno. All rights reserved.
//
import UIKit

class SubViewController: UIViewController {
    
    var subWeb: CustomWebView!
    var rtnUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subWeb = CustomWebView()
        subWeb.initView(sender: self, navi: "sub")
        subWeb.goLink(urlString: rtnUrl)
    }
    
    /* when screen position is changed   */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            subWeb.customWeb.frame = CGRect(x: 0 , y: 0, width: width, height: height)
        }else{
            subWeb.customWeb.frame = CGRect(x: 0 , y: 20, width: width, height: height-20)
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let sendtimer=segue.destinationViewController as! MainView
        //sendtimer.time=String(time)
        
    }
    
    /* Memory management  */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
