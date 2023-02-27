//
//  DFWebView.swift
//  DFSDKApp
//
//  Created by qianduan-lianggq on 2023/2/10.
//

import UIKit
import WebKit


class DFWebView: WKWebView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    /// web代理
    @objc public weak var webProxy: WKNavigationDelegate?
    /// 页面
    @objc public weak var containerVc: UIViewController?
    /// config
    @objc private static var configuration: WKWebViewConfiguration{
        struct DFWWebConfigStruct {
            static var configIns: WKWebViewConfiguration? = nil
        }
        var configuration = DFWWebConfigStruct.configIns
        if(configuration == nil){
            configuration = WKWebViewConfiguration.init()
            let preferences = WKPreferences.init()
            preferences.javaScriptCanOpenWindowsAutomatically = true
            preferences.javaScriptEnabled = true
            configuration?.preferences = preferences
            configuration?.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            configuration?.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
            let userContent = WKUserContentController.init()
            configuration?.userContentController = userContent
            configuration?.websiteDataStore = WKWebsiteDataStore.default()
            DFWWebConfigStruct.configIns = configuration
        }
        configuration?.userContentController.removeAllUserScripts()
        return configuration!
    }
    //userAgent
    @objc private static var userAgent: String = ""
    @objc private var userAgentWeb: WKWebView?
    ///userAgent标识
    @objc private static var userAgentFlag: String = "-DF-APP"
    
    
    //MARK: Override
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience public init(frame: CGRect){
        self.init(frame: frame, configuration: nil)
        self.backgroundColor = UIColor.white
    }
    
    override public init(frame: CGRect, configuration: WKWebViewConfiguration?) {
        let config = (configuration != nil) ? configuration! : Self.configuration
        super.init(frame: frame, configuration: config)
        //
        self.scrollView.bounces = true
        self.backgroundColor = UIColor.white
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.navigationDelegate = self
        self.uiDelegate = self
        self.allowsLinkPreview=false
        //为解决ios12 useragent不生效问题
        if Self.userAgent != "" {
            self.customUserAgent = Self.userAgent + Self.userAgentFlag
        }else {
            let fakeView = WKWebView.init(frame: frame, configuration: config)
            self.userAgentWeb = fakeView
            fakeView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
                if error == nil && result != nil{
                    if let agent = result as? String {
                        Self.userAgent = agent
                        let userAgent = agent +  Self.userAgentFlag
                        self?.customUserAgent = userAgent
                    }
                }
                self?.userAgentWeb = nil
            }
        }
    }
    
    //MARK: public method
    @objc dynamic public func setJsCurrentPageSelf(){
        weak var wekSelf = self
        self.removeJsUserSelf()
        self.configuration.userContentController.add(wekSelf!, name: "DFWWebKitHander")
    }
    
    @objc dynamic public func removeJsUserSelf(){
        self.configuration.userContentController.removeScriptMessageHandler(forName: "DFWWebKitHander")
    }
    
    @discardableResult
    @objc dynamic public func loadString(_ urlStr: String?) -> WKNavigation? {
        if(urlStr == nil){
            return nil
        }
        var url : URL?
        var urlUT8 = urlStr!
        if urlStr!.contains("%") == false { //不包含则去encoding
            var charSet = CharacterSet.urlQueryAllowed
            charSet.insert(charactersIn: "#")
            guard let encodingStr = urlStr?.addingPercentEncoding(withAllowedCharacters: charSet) else {
                return nil
            }
            urlUT8 = encodingStr
        }
        if(urlStr!.hasPrefix("file") || urlStr!.hasPrefix("/")){
            url = URL.init(fileURLWithPath: urlUT8)
        }else {
            url = URL.init(string: urlUT8)
        }
        return self.loadRequestWith(url)
    }
    
    @discardableResult
    @objc dynamic public func loadRequestWith(_ url: URL?) -> WKNavigation? {
        if(url == nil) {
            return nil
        }
        //加载
        let policy: URLRequest.CachePolicy = .useProtocolCachePolicy
        var request = URLRequest.init(url: url!, cachePolicy: policy, timeoutInterval: 0.0)
        request.httpShouldHandleCookies = true
        return self.load(request)
    }
    
    deinit {
    }

}

extension DFWebView {
    //MARK: WKScriptMessageHandler
    @objc dynamic public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DFWebCommand.webCommand(didReceive: message.body, webView: self)
    }
}

extension DFWebView {
    //MARK: WKWebViewDelegate
    @objc dynamic public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        if let url = navigationAction.request.url {
            //iTunes  scheme
            if url.host == "itunes.apple.com" {
                let appURL = url
                if UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    return
                }
            }
            //解决html <a>标签的属性target = "_blank"无法跳转问题
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void){
        
        self.webProxy?.webView?(webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler)
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.webProxy?.webView?(webView, didCommit: navigation)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webProxy?.webView?(webView, didFinish: navigation)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.webProxy?.webView?(webView, didFail: navigation, withError: error)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.webProxy?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    @objc dynamic public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.webProxy?.webViewWebContentProcessDidTerminate?(webView)
    }
    
    //MARK: WKUIDelegate
    @objc dynamic public func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        //window.alert()
        completionHandler()
    }
    
    @objc dynamic public func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        //window.confirm()
        completionHandler(true)
    }
    
    @objc dynamic public func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        completionHandler(defaultText)
    }
    
}


extension DFWebView {
    @objc dynamic public class func setUAgentFlag(_ flag: String) {
        self.userAgentFlag = flag
    }
}
