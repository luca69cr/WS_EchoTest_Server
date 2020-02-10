//
//  File.swift
//  WS_EchoTest_Server
//
//  Created by Luca MURATORE on 09/02/2020.
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif
import Foundation

import PerfectLib

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}


class Event: JSONConvertibleObject {
    var evtClass: String = ""
    /// is a server timestamp for message send or received
    var evtSRtime: Int64 = Date().toMillis()
}


class SignalEvent: Event {
    enum CodeType : UInt8 {
        case INVALID = 0x00,
        NONAME = 0x01,
        HELLO = 0x02
    }
    static let registerName = "SignalEvent"
    //var evtClassName: String = ""
    var appKey: String = ""
    var code: UInt8 = 0x00
    

    
    override func setJSONValues(_ values: [String : Any]) {
        //self.evtClassName =
        self.evtClass=SignalEvent.registerName
        self.evtSRtime = getJSONValue(named: "evtSRtime", from: values, defaultValue: 0)
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        self.code = getJSONValue(named: "code", from: values, defaultValue: 0x00)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:SignalEvent.registerName,
            "evtSRtime": self.evtSRtime,
            "evtClass": SignalEvent.registerName,
            "appKey": appKey,
            "Code": code,
        ]
    }
}


/**
 
 */
class ApplicationMessage: Event {
    
    static let registerName = "ApplicationMessage"
    var appKey: String = ""
    var appMsg: String = ""
    var appDataDic=Dictionary<String, Any>()
    //var appDataDic: [String:Any] = [:] ///dictionary of data message
    var appMsgPart = 0
    
    /**
     
     */
    override func setJSONValues(_ values: [String : Any]) {
        self.evtClass=ApplicationMessage.registerName
        self.evtSRtime = getJSONValue(named: "evtSRtime", from: values, defaultValue: 0)
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        self.appMsg = getJSONValue(named: "appMsg", from: values, defaultValue: "")
        self.appDataDic = getJSONValue(named: "appDataDic", from: values, defaultValue: [:])
        self.appMsgPart = getJSONValue(named: "appMsgPart", from: values, defaultValue: 0)
    }
    
    /**
     
     */
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:ApplicationMessage.registerName,
            "evtSRtime": self.evtSRtime,
            "appKey":appKey,
            "appMsg":appMsg,
            "appDataDic":appDataDic,
            "appMsgPart":appMsgPart
        ]
    }
}
