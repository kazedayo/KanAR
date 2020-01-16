//
//  ViewController+UIWebViewDelegate.swift
//  KanAR
//
//  Created by Kin Wa Lam on 6/1/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit

extension ViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let contentSize = webView.scrollView.contentSize
        let webViewSize = webView.bounds.size
        let scaleFactor = webViewSize.width / contentSize.width

        webView.scrollView.minimumZoomScale = scaleFactor
        webView.scrollView.maximumZoomScale = scaleFactor
        webView.scrollView.zoomScale = scaleFactor
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //Inject JS
        let asvgPath = Bundle.main.path(forResource: "asvg", ofType: "js")
        let asvgjs = try! String(contentsOfFile: asvgPath!)
        webView.stringByEvaluatingJavaScript(from: asvgjs)
        let infinitePath = Bundle.main.path(forResource: "infinite", ofType: "js")
        let infinitejs = try! String(contentsOfFile: infinitePath!)
        webView.stringByEvaluatingJavaScript(from: infinitejs)
        return true
    }
}
