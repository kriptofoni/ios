//
//  NewsController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 6.05.2021.
//

import UIKit
import WebKit

class NewsController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let url = URL(string: "https://www.investing.com/") else{
          return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
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
