//
//  WebViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 28.10.22.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var site: WebSites = .policy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: site.rawValue)!
        webView.load(URLRequest(url: url))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
