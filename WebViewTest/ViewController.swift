//
//  ViewController.swift
//  WebViewTest
//
//  Created by Recep Burunkaya on 5/14/23.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        // WebView Configuration Settings
        let webConfiguration = WKWebViewConfiguration()
        
        let pref = WKWebpagePreferences.init()
        pref.preferredContentMode = .mobile
        webConfiguration.defaultWebpagePreferences = pref
        
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let myURL = URL(string: "Capture_App_URL")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    // Passing Camera Permission Optional
    @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
            decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
            initiatedBy frame: WKFrameInfo,
            type: WKMediaCaptureType) async -> WKPermissionDecision {
                return .grant;
        }
}
