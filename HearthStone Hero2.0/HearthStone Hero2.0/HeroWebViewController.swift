//
//  HeroWebViewController.swift
//  Hearthstone Hero
//
//  Created by Tianshu Xu on 04/03/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import UIKit
import WebKit

class HeroWebViewController: UIViewController, WKNavigationDelegate {

    // outlets
    @IBOutlet weak var urlTextView: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    var urlData : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Web Page"
        
        // make the webView to display the url
        let url = URL(string: "https://" + urlData)
        let request = URLRequest(url: url!)
        
        webView.load(request)
        webView.navigationDelegate = self
        urlTextView.text = "https://" + urlData
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
