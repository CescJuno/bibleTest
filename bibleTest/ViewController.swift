//
//  ViewController.swift
//  bibleTest
//
//  Created by Duranno on 2017. 8. 1..
//  Copyright © 2017년 Duranno. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var btnBack: UIButton!
    @IBAction func goPrev(_ sender: Any) {
        mainWeb.goPrev()
    }
    var mainWeb: CustomWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mainWeb = CustomWebView()
        mainWeb.initView(sender: self, navi: "main")
        mainWeb.goLink(urlString: "http://whoisaus.com")
        
        view.bringSubview(toFront: btnBack)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subview" {
            if let controller = segue.destination as? SubViewController {
                controller.rtnUrl = mainWeb.curUrl
            }
        }
        //sendtimer.time=String(time)
        
    }
    /* when screen position is changed   */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            mainWeb.customWeb.frame = CGRect(x: 0 , y: 0, width: width, height: height)
        }else{
            mainWeb.customWeb.frame = CGRect(x: 0 , y: 20, width: width, height: height-20)
        }
    }


}

