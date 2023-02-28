//
//  DFManager.swift
//  DFSDKApp
//
//  Created by qianduan-lianggq on 2023/2/10.
//

import UIKit


public class DFManager: NSObject {
    ///单列对象
    @objc private static let singleton = DFManager()
        
    /// 私有构建方法
    private override init() {
        super.init()
    }
    
    /// 单例方法
    @objc dynamic public class func shareSingleton() -> DFManager {
        return self.singleton
    }
    
}


//MARK: 业务API
extension DFManager {
    /// 设置h5全局userAgent的标识
    /// - Parameter uaFlag:     标识
    @objc dynamic public func setUserAgentFlag(_ uaFlag: String) {
        DFWebView.setUAgentFlag(uaFlag)
    }
    
    /// 唤起web页面
    /// - Parameters:
    ///   - currentPage:    当前页面
    ///   - url:            跳转url
    ///   - params:         参数
    @objc dynamic public func openWebPage(_ currentPage: UIViewController,
                                          url: String,
                                          params: Dictionary<String, Any> = [:]) {
        let webVc = DFWebViewController()
        webVc.requestUrlStr = url
        let title = params["webTitle"] as? String
        webVc.webTitle = title ?? ""
        if let navi = currentPage as? UINavigationController {
            navi.pushViewController(webVc, animated: true)
        }else {
            if let navi = currentPage.navigationController {
                navi.pushViewController(webVc, animated: true)

            }else {
                let naiv = UINavigationController(rootViewController: webVc)
                currentPage.present(naiv, animated: true)
            }
        }
    }
    
    /// 唤起扫码页面
    /// - Parameters:
    ///   - currentPage:    当前页面
    ///   - callback:       返回扫码结果
    @objc dynamic public func openScan(_ currentPage: UIViewController,
                                       callback:@escaping ((_ result: String) ->Void)) {
        let vc = DFWQRScanViewController.init()
        vc.modalPresentationStyle = .fullScreen
        vc.isPresentType = true
        vc.getResultUrl { (result) in
            callback(result)
        }
        currentPage.present(vc, animated: true)
    }
    
    /// 获取定位经纬度
    /// - Parameter result: 返回latitude, latitude
    @objc dynamic public func getLocation(_ result: @escaping ((_ latitude: String,
                                                                _ longitude: String) ->Void)) {
        let locationManager = DFLocationManager.singleton
        locationManager.locationDidUpdatedCallback = { (loction) in
            if let loc = loction {
                let coordinate = loc.coordinate
                result(String(coordinate.latitude), String(coordinate.longitude))
            }else {
                result("", "")
            }
        }
        locationManager.startUpdatingLocation()
    }
}
