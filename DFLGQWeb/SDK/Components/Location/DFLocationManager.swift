//
//  DFLocationManager.swift
//  DFSDKApp
//
//  Created by qianduan-lianggq on 2023/2/20.
//

import UIKit
import CoreLocation

typealias DFLocationResutBlock = (_ latitudeString:String, _ longitudeString:String) ->Void

class DFLocationManager: NSObject {
    ///单列对象
    @objc public static let singleton = DFLocationManager()
    ///定位数据回调
    @objc public var locationDidUpdatedCallback: ((_ location: CLLocation?) -> Void)? = nil
    ///定位管理
    @objc private let locationManager: CLLocationManager = CLLocationManager()
    ///上次获取权限
    @objc private var lastTimeStatus: CLAuthorizationStatus = .notDetermined
    ///上次定位结果
    @objc private var lastLocation: CLLocation?
    
    
    /// 私有构建方法
    private override init() {
        super.init()
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        if let infoConfig = Bundle.main.infoDictionary {
            if let modes = infoConfig["UIBackgroundModes"] as? Array<String>, modes.contains("location") {
                //配置了可后台定位
                locationManager.allowsBackgroundLocationUpdates = true
            }
        }
    }
    
    /// 开启定位
    @objc dynamic public func startUpdatingLocation() {
        let loctionEnable = CLLocationManager.locationServicesEnabled()
        if !loctionEnable {
            self.alertLocationDisenabledStauts("设备定位服务未开启", message: "开启定位即可使用此服务，请前往开启。")
        }
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
            if status == .denied && loctionEnable {
                let appName = (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
                self.alertLocationDisenabledStauts("定位权限未开启", message: "请在设置中开启\(appName)定位权限")
            }
            locationManager.startUpdatingLocation()
        }
        lastTimeStatus = status
    }
    
    /// 取消定位
    @objc dynamic public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 定位权限关闭弹框提示
    @objc dynamic private func alertLocationDisenabledStauts(_ title: String,
                                                             message: String) {
        
        let locationTipsAlert = UIAlertController(title: title,
                                                  message: message,
                                                  preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "取消",
                                              style: .default) { (action) in
        }
        let settingAction = UIAlertAction.init(title: "去设置",
                                               style: .default) { (action) in
            if let url = URL.init(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { (success) in
                    
                }
            }
        }
        locationTipsAlert.addAction(cancelAction)
        locationTipsAlert.addAction(settingAction)
        if let rootVc = UIApplication.shared.delegate?.window??.rootViewController {
            rootVc.present(locationTipsAlert, animated: true, completion: nil)
        }
    }
    
}


extension DFLocationManager: CLLocationManagerDelegate {
    //MARK: CLLocationManagerDelegate
    @objc dynamic func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if lastTimeStatus == .notDetermined && status != lastTimeStatus {
            locationManager.startUpdatingLocation()
        }
        lastTimeStatus = status
    }

    @objc dynamic func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.stopUpdatingLocation()
        if let currenLoction = locations.last {
            print("定位经纬度：\(currenLoction.coordinate.longitude), \(currenLoction.coordinate.latitude)")
            if let lastObjct = lastLocation {
                //计算2次结果是否相同(解决单次定位多次数据返回问题)
                if currenLoction.isEqualWithCoordinate(lastObjct) {
                    return
                }
            }
            lastLocation = currenLoction
            locationDidUpdatedCallback?(currenLoction)
        }
    }
    
    @objc dynamic func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败：\(error)")
        self.stopUpdatingLocation()
        locationDidUpdatedCallback?(nil)
    }
}




private extension CLLocation  {
    
    /// 定位数据是否相同（针对经纬度）
    /// - Parameter other:
    /// - Returns:
    @objc dynamic func isEqualWithCoordinate(_ other: CLLocation) -> Bool {
        if self == other {
            return true
        }
        let thisCoordinate  = self.coordinate
        let otherCoordinate = other.coordinate
        let deviation: CLLocationDegrees = 0.0000001
        if (thisCoordinate.latitude - otherCoordinate.latitude) < deviation &&
            (thisCoordinate.longitude - otherCoordinate.longitude) < deviation {
            //两者经纬度偏差小于0.0000001内，认为定位数据相同
            return true
        }
        return false
    }
    
    
}

