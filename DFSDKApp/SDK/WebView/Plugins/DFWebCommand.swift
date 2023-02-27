//
//  DFWebCommand.swift
//  DongFuWang
//
//  Created by lianggq on 2020/11/3.
//

import UIKit


let kDWFWebCallbackTag      = "callbackTag"

let kDFWWebMethodName       = "methodName"


/// - js传的方法名
enum DFWebCommandMethodType: String {
    case Unkown             = ""                            //
    case OpenScan           = "openAppScan"                 //打开扫码页
    case GetGpsLoc          = "getGpsLoc"                   //获取定位经纬度

}


/// - 回调的状态码
enum DFWebCommandCallBackCodeType: String {
    case Success                    = "0"                           //成功
    case NotFound                   = "-1"                          //方法未找到
    case Failure                    = "-2"                          //失败

}


@objc protocol DFWebCommandDelegate: NSObjectProtocol {
    
    /// native回调js处理
    ///
    /// - Parameters:
    ///   - respData:       回调参数
    ///   - webView:        webView载体（webView可能被pop导致nil)
    func commandJsCompletedCallback(respData: Dictionary<String, Any>, webView: DFWebView?)
    
}



class DFWebCommand: NSObject, DFWebCommandDelegate {
    
    @objc private static let sharedCommand: DFWebCommand = {
        let share = DFWebCommand.init()
        return share
    }()
    
    private override init() {
        super.init()
    }
    
    //MARK: 接收js方法参数
    @objc dynamic public class func webCommand(didReceive message: Any, webView: DFWebView) {
        guard message is Dictionary<String, Any> else {
            return
        }
        let body = message as! Dictionary<String, Any>
        //Pugins
        var plugin: DFH5Plugin?
        if let methodName = (body[kDFWWebMethodName] as? String),
            let methodType = DFWebCommandMethodType(rawValue: methodName){
            //如果找到方法名
            switch methodType {
            case .GetGpsLoc:
                plugin = DFH5LocationPlugin()
                break
            case .OpenScan:
                plugin = DFH5ScanPlugin()
                break
            default:
                break
            }
            plugin?.webView = webView
            plugin?.delegate = DFWebCommand.sharedCommand
            plugin?.handlerJsMessage(message: body)
        }else {
            var respData = Dictionary<String, Any>()
            respData["code"] = DFWebCommandCallBackCodeType.NotFound.rawValue
            if(body[kDWFWebCallbackTag] != nil){
                respData[kDWFWebCallbackTag] = body[kDWFWebCallbackTag]
            }
            DFWebCommand.sharedCommand.commandJsCompletedCallback(respData: respData,
                                                                   webView: webView)
        }
        
    }
    
    
    
    //MARK: DFWWebCommandDelegate
    @objc dynamic func commandJsCompletedCallback(respData: Dictionary<String, Any>,
                                                  webView: DFWebView?) {
        if(webView == nil){
            return
        }
        var jsParams: Dictionary<String, Any>? = nil
        if(JSONSerialization.isValidJSONObject(respData)){
            jsParams = respData
        }else{
            jsParams = Dictionary<String, Any>()
            jsParams!["code"] = DFWebCommandCallBackCodeType.Failure.rawValue
            if(respData[kDWFWebCallbackTag] != nil){
                jsParams![kDWFWebCallbackTag] = respData[kDWFWebCallbackTag]
            }
        }
        let data = try? JSONSerialization.data(withJSONObject: jsParams!, options: [])
        let codeStr = String(data: data!, encoding: String.Encoding.utf8)
        let codeString = "dfwNativeCallback( \(codeStr!) )"
        webView?.evaluateJavaScript(codeString) { (result, err) in
            if(err != nil){
                print("evaluate callback error: \(String(describing: err))" )
            }
        }
    }
}
