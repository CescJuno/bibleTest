//
//  CustomWebView.swift
//  bibleTest
//
//  Created by Duranno on 2017. 8. 1..
//  Copyright © 2017년 Duranno. All rights reserved.
//

import UIKit
import WebKit

protocol webProt {
    var isNavi: String {get set}
    var curUrl: String {get set}
    var parent: AnyObject! {get set}
    var loadingView: UIView! {get set}
    var actInd: UIActivityIndicatorView!{get set}
    func initView(sender: AnyObject, navi: String)
    func goLink(urlString: String)
    func excutePostLink(urlString: String, params: String)
    func goPrev()
    func goNext()
    func goRefresh()
    func goOtherView(_ curUrl:URLRequest)
    func goSubView(resVal: String)
}
class CustomWebView: WKWebView,WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,webProt {
    var parent: AnyObject!
    var refreshControl: UIRefreshControl!
    var actInd: UIActivityIndicatorView!
    var curUrl: String = ""
    var isNavi: String = ""
    var customWeb: WKWebView!
    var loadingView: UIView!
    func initView(sender: AnyObject, navi: String){
        parent = sender
        isNavi = navi
        let userContentController = WKUserContentController()
        if let cookies = HTTPCookieStorage.shared.cookies {
            let script = getJSCookiesString(cookies: cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            userContentController.addUserScript(cookieScript)
        }
        
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        self.customWeb = WKWebView(frame: CGRect(x:0,y:20,width:sender.view.frame.size.width, height: sender.view.frame.size.height-20), configuration: webViewConfig)
        self.customWeb.uiDelegate = self
        self.customWeb.navigationDelegate = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action:#selector(self.refresh), for: UIControlEvents.valueChanged)
        self.customWeb.scrollView.addSubview(refreshControl) // not required when using UITableViewController
        
        sender.view.addSubview(self.customWeb)
        
        initIndicator(uiView: sender.view)
    }
    
    func initIndicator(uiView: UIView) {
        
        self.loadingView = UIView()
        self.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80) //CGRectMake(0, 0, 80, 80)
        self.loadingView.center = uiView.center
        self.loadingView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 10
        
        self.actInd = UIActivityIndicatorView()
        self.actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        self.loadingView.addSubview(self.actInd)
        uiView.addSubview(self.loadingView)
        
        self.loadingView.isHidden = true
        
    }
    func refresh(sender: UIRefreshControl) {
        // Code to refresh table view
        self.customWeb.reload()
        sender.endRefreshing()
    }
    /*
     Page load
     method: GET
     */
    func goLink(urlString: String){
        let url = URL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,timeoutInterval: 30.0)
        
        request.httpMethod = "GET"
        let bodyData: String = ""
        request.addValue(bodyData, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.customWeb.load(request as URLRequest)
                }else{
                    //self.goErrorPage()
                }
            }else{
                //self.goErrorPage()
            }
        }
        task.resume()
    }
    
    /*
     Page load
     method: POST
     */
    func excutePostLink(urlString: String, params: String){
        let url = URL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,timeoutInterval: 30.0)
        
        request.httpMethod = "POST"
        let bodyData: String = params
        request.addValue(bodyData, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.customWeb.load(request as URLRequest)
                }else{
                    //self.goErrorPage()
                }
            }else{
                //self.goErrorPage()
            }
        }
        task.resume()
    }
    func goPrev(){
        if self.customWeb.canGoBack == true {
            self.customWeb.goBack()
        }
    }
    func goNext(){
        if self.customWeb.canGoForward == true {
            self.customWeb.goForward()
        }
    }
    func goRefresh(){
        self.customWeb.reload()
    }
    
    /* safari로 이동 */
    func goOtherView(_ curUrl:URLRequest){
        UIApplication.shared.open(curUrl.url!, options: [:], completionHandler: nil)
    }
    func goSubView(resVal: String){
        curUrl = resVal
        parent.performSegue(withIdentifier: "subview", sender: parent)
    }
    // WKWebView UI Delegate
    
    /**
     *  Javascript Window.open Event
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.description.lowercased().range(of: "http://") != nil ||
                url.description.lowercased().range(of: "https://") != nil ||
                url.description.lowercased().range(of: "mailto:") != nil {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return nil
    }
    
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        
    }
    
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
    
    /**
     *  Javascript Alert 창
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert);
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
            _ in completionHandler()}
        )
        
        let rootViewController: UIViewController = (UIApplication.shared.windows.last?.rootViewController)!
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    /**
     *  Javascript Comfirm 창
     */
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert);
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            _ in completionHandler(false)}
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            _ in completionHandler(true)}
        )
        let rootViewController: UIViewController = (UIApplication.shared.windows.last?.rootViewController)!
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }
    
    
    
    // WKWebView Navigation Delegate
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //self.loadingView.isHidden = true
        //self.actInd.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingView.isHidden = true
        self.actInd.stopAnimating()
        
        
        if self.customWeb.canGoBack == true {
            
        }
        curUrl = (webView.url!.absoluteString)
        print("Webview did finish load");
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingView.isHidden = false
        self.actInd.startAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loadingView.isHidden = true
        self.actInd.stopAnimating()
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let urlResponse = navigationResponse.response as? HTTPURLResponse,
            let url = urlResponse.url,
            let allHeaderFields = urlResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
            HTTPCookieStorage.shared.setCookies(cookies , for: urlResponse.url!, mainDocumentURL: nil)
            decisionHandler(.allow)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let curUrl = navigationAction.request.url!.absoluteString
        //if (navigationAction.navigationType == .linkActivated){
        //   decisionHandler(.cancel)
        //} else {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        if ((curUrl.range(of: "phobos.apple.com") != nil) || (curUrl.range(of: "itunes.apple.com") != nil)){
            goOtherView(navigationAction.request)
            decisionHandler(.cancel)
            return
        }else if((curUrl.hasPrefix("http")) || (curUrl.hasPrefix("https")) || (curUrl.hasPrefix("about")) || (curUrl.hasPrefix("file"))){
            //if navigationType == UIWebViewNavigationType.LinkClicked{
            if isNavi == "main" {
                /*
                 if(curUrl.range(of: "/search") != nil){
                 goSubView(resVal: curUrl)
                 decisionHandler(.cancel)
                 return
                 }
                 */
            }else{
                
            }
        }else if(curUrl.range(of: "kakaolink:") != nil){
            decisionHandler(.cancel)
            return
        }else{
            let strUrl2:String = "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=369125087&;mt=8"
            if let strUrl1:URL = URL(string:strUrl2) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(strUrl1, options: [:], completionHandler: {
                        (success) in
                        //print("Open \(scheme): \(success)")
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(strUrl1)
                }
                decisionHandler(.cancel)
                return
            }
            
        }
        
        decisionHandler(.allow)
        //}
        
        
        
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //self.loadingView.isHidden = true
        //self.actInd.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.loadingView.isHidden = true
        self.actInd.stopAnimating()
    }
    
    
    //Generates script to create given cookies
    private func getJSCookiesString(cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    
}
