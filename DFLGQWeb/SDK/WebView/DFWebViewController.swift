//
//  DFWebViewController.swift
//  DFSDKApp
//
//  Created by qianduan-lianggq on 2023/2/10.
//

import UIKit
import WebKit

class DFWebViewController: UIViewController, WKNavigationDelegate {
    ///访问地址
    @objc public var requestUrlStr: String = ""
    ///标题
    @objc public var webTitle: String = ""
    ///webview
    @objc private lazy var webView: DFWebView = {
        let webView = DFWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.webProxy = self
        webView.containerVc = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        return webView
    }()
    ///进度条
    @objc private lazy var progressView: UIProgressView = {
        let proView = UIProgressView()
        proView.translatesAutoresizingMaskIntoConstraints = false
        proView.tintColor = UIColor.blue // 进度条背景色
        proView.trackTintColor = UIColor.white
        return proView
    }()
    /// 是否可以系统右滑动返回，
    @objc private var isRecordCanPopGestureRecognizer: Bool = true
    ///不支持旋转
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    
    //MARK: override
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigateBar()
        self.setupViews()
        self.canPopWithGesture(true)
        self.title = self.webTitle
        // 强制关闭暗黑模式
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        self.loadWeb(requestUrlStr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.setJsCurrentPageSelf()
        self.canPopWithGesture(self.isRecordCanPopGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.removeJsUserSelf()
        self.canPopWithGesture(true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let estimatedProgress = self.webView.estimatedProgress
            self.progressView.setProgress(Float(estimatedProgress), animated: true)
            self.progressView.alpha = 1.0
            if estimatedProgress >= 0.75 {
                self.progressView.setProgress(1.0, animated: true)
                UIView.animate(withDuration: 0.3) {
                    self.progressView.alpha = 0.0
                } completion: { (finish) in
                    self.progressView.isHidden = true
                }
            }
        }else if keyPath == "canGoBack" {
            self.canPopWithGesture(!self.webView.canGoBack)
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //MARK: private
    @objc dynamic private func loadWeb(_ urlStr: String) {
        self.progressView.isHidden = false
        self.progressView.setProgress(0.0, animated: false)
        self.webView.loadString(urlStr)
    }
    
    @objc dynamic public func close() {
        if let nav = self.navigationController,
           nav.viewControllers.count > 0 {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: {})
        }
    }
    
    @objc dynamic public func goBack() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }else {
            self.close()
        }
    }
    
    @objc dynamic private func canPopWithGesture(_ isCanPop: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isCanPop
        self.isRecordCanPopGestureRecognizer = isCanPop
    }
    
    //MARK: setup
    @objc dynamic private func setupNavigateBar() {
        let backImage = UIImage(named: "df_return_back")?.withRenderingMode(.alwaysOriginal)
        let leftBar = UIBarButtonItem.init(image: backImage,
                                           style: .plain,
                                           target: self,
                                           action: #selector(goBack))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = [leftBar]
    }

    @objc dynamic private func setupViews() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.webView)
        self.webView.addSubview(self.progressView)
        //
        let webTop  = NSLayoutConstraint.init(item: webView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0)
        let webLeft = NSLayoutConstraint.init(item: webView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let webRight = NSLayoutConstraint.init(item: webView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let webBottom = NSLayoutConstraint.init(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([webTop, webLeft, webRight, webBottom])
        let progTop = NSLayoutConstraint.init(item: progressView, attribute: .top, relatedBy: .equal, toItem: webView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let progLeft = NSLayoutConstraint.init(item: progressView, attribute: .left, relatedBy: .equal, toItem: webView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let progRight = NSLayoutConstraint.init(item: progressView, attribute: .right, relatedBy: .equal, toItem: webView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let progHeight = NSLayoutConstraint.init(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1.0)
        self.webView.addConstraints([progTop, progLeft, progRight])
        self.progressView.addConstraint(progHeight)
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "canGoBack")
    }
    
}


extension DFWebViewController {
    //MARK: WKWebViewDelegate
    @objc dynamic func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //有数据返回
    }
    
    @objc dynamic func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //加载完成
    }
    
    @objc dynamic func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //加载失败
    }
    
    @objc dynamic func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //
    }

    @objc dynamic func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }
}
