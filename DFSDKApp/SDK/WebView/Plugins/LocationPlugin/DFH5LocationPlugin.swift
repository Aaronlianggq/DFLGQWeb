//
//  DFH5LocationPlugin.swift
//  DongFuWang
//
//  Created by lianggq on 2020/11/3.
//

import UIKit


class DFH5LocationPlugin: DFH5Plugin {
    
    override func handlerJsMessage(message: Dictionary<String, Any>) {
        super.handlerJsMessage(message: message)
        let methodName = message["methodName"] as! String
        switch DFWebCommandMethodType(rawValue: methodName)! {
        case .GetGpsLoc:
            self.getGpsLoc(message: message)
            break
            
        default: break
        }
    }
    
    //MARK:
    @objc dynamic private func getGpsLoc(message: Dictionary<String, Any>) {
        var respData = self.getRespDataWith(message: message)
        DFManager.shareSingleton().getLocation { (latitude, longitude) in
            var data = Dictionary<String, Any>()
            data["latitude"] = String(latitude)
            data["longitude"] = String(longitude)
            respData["data"] = data
            if latitude.isEmpty || longitude.isEmpty {
                respData["code"] = DFWebCommandCallBackCodeType.Failure.rawValue
            }else {
                respData["code"] = DFWebCommandCallBackCodeType.Success.rawValue
            }
            self.delegate?.commandJsCompletedCallback(respData: respData,
                                                       webView: self.webView)
        }
    }
}
