//
//  ReWebview.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import WebKit

/**
 * WKWebView wrapper with reactive node feature
 */
public class ReWebView : ReactiveNode<URLRequest>, WKNavigationDelegate {
    
    var webview : WKWebView? {
        return self.view as? WKWebView
    }
    
    var isURLLoaded = false
    
    public var onLoadWebview : ((WKWebView) -> Void)?
    
    public override init() {
        super.init()
        
        self.setViewBlock {
            WKWebView()
        }
        
        self.webview?.navigationDelegate = self
    }
    
    public convenience init(_ url: String) {
        self.init()
        
        guard let url = URL(string: url) else {
            return
        }
        
        self.onPropsDidSet(props: URLRequest(url: url))
    }
    
    public convenience init(_ url: URL) {
        self.init()
        self.onPropsDidSet(props: URLRequest(url: url))
    }
    
    public convenience init(_ url: URLRequest) {
        self.init()
        self.onPropsDidSet(props: url)
    }
    
    public override func didLoad() {
        super.didLoad()
        
        guard let prop = self.props else {
            return
        }
        
        self.reactiveBind(obx: Observable.just(prop))
    }
    
    public override func reactiveBind(obx: Observable<URLRequest>) {
        super.reactiveBind(obx: obx.distinctUntilChanged())
    }
    
    public override func renderState(value: URLRequest) {
        self.isURLLoaded = true
        self.webview?.load(value)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.onLoadWebview?(webView)
    }
}

