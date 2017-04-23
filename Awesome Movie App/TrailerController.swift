//
//  TrailerController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 23/04/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class TrailerController: UIViewController {
    
    private static let youtubeEmbedUrl = "https://www.youtube.com/embed/"

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var youtubeVideoId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func youtubeUrlForVideoId(_ videoId:String) -> String {
        return "\(TrailerController.youtubeEmbedUrl)\(videoId)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.desiredOrientation = UIInterfaceOrientationMask.landscape
        }
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        loadRequest()
    }
    
    func loadRequest() {
        if let youtubeId = youtubeVideoId, let url = URL(string: TrailerController.youtubeUrlForVideoId(youtubeId)) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            // this should not happen in any scenario - missing or wrong id should mean no play button in movie detail
            let alert = UIAlertController(title: "Invalid ID", message: "The trailer video ID is invalid.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // another to do nothing, just move back from trailer
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(doneAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.desiredOrientation = UIInterfaceOrientationMask.portrait
        }
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TrailerController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        webView.isHidden = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let alert = UIAlertController(title: nil, message: "An error occured trying to load the trailer. If you are offline, connect to the internet and try again.", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
            // one possibility is to try again
            self.loadRequest()
        })
        let doneAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // another to do nothing, just move back from trailer
                self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(tryAgainAction)
        alert.addAction(doneAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
