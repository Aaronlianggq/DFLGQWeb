//
//  DFH5ScanPlugin.swift
//  DongFuWang
//
//  Created by qianduan2731 on 2022/1/17.
//

import UIKit

class DFH5ScanPlugin: DFH5Plugin {
    override func handlerJsMessage(message: Dictionary<String, Any>) {
        super.handlerJsMessage(message: message)
        let methodName = message["methodName"] as! String
        switch DFWebCommandMethodType(rawValue: methodName)! {
        case .OpenScan:
            self.openScan(message: message)
            break
        default: break
        }
    }
    
    //MARK:
    @objc dynamic private func openScan(message: Dictionary<String, Any>) {
        var respData = self.getRespDataWith(message: message)
        var data = self.getDataDict()
        if let currentVc = self.webView?.containerVc {
            DFManager.shareSingleton().openScan(currentVc) { (result) in
                //扫码结果
                if result == "" {
                    respData["code"] = DFWebCommandCallBackCodeType.Failure.rawValue
                    data["resultUrl"] = ""
                }else{
                    respData["code"] = DFWebCommandCallBackCodeType.Success.rawValue
                    data["resultUrl"] = result
                }
                respData["data"] = data
                self.delegate?.commandJsCompletedCallback(respData: respData, webView: self.webView)
            }
        }else {
            respData["code"] = DFWebCommandCallBackCodeType.Failure.rawValue
            data["resultUrl"] = ""
            self.delegate?.commandJsCompletedCallback(respData: respData, webView: self.webView)
        }
    }
}
