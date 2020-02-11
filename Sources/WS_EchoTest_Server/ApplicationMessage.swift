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
    var evtClassName: String = ""
    /// is a server timestamp for message send or received
    let evtSRtime: Int64 = Date().toMillis()
    var code: UInt8 = 0x00
}

/**
 
 */
 class SignalEvent: Event {
    static let registerName = "SignalEvent"
    //var evtClassName: String = "Event"
    /// is a server timestamp for message send or received
    //let evtSRtime: Int64 = Date().toMillis()
    //var code: UInt8 = 0x00
    var appKey: String = ""
   
    
    override func setJSONValues(_ values: [String : Any]) {
        //self.evtClassName =
        self.evtClassName=getJSONValue(named: "evtClassName", from: values, defaultValue: "")
        //self.evtSRtime = getJSONValue(named: "evtSRtime", from: values, defaultValue: 0)
        self.code = getJSONValue(named: "code", from: values, defaultValue: 0x00)
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:SignalEvent.registerName,
            "evtSRtime": self.evtSRtime,
            "evtClassName": evtClassName,
            "appKey": appKey,
            "Code": code
        ]
    }
}


/**
 
 */
 class DataEvent: Event {
    
    static let registerName = "DataEvent"
    /// var evtClassName: String
    /// is a server timestamp for message send or received
    ///  evtSRtime: Int64
    /// var code: UInt8
    var appKey: String = ""
    //var appMsg: String = ""
    var DataDic=Dictionary<String, Any>()
    //var code: UInt8 = 0x00
    
    
    /**
     
     */
    override func setJSONValues(_ values: [String : Any]) {
        self.evtClassName=getJSONValue(named: "evtClassName", from: values, defaultValue: "")
        self.code = getJSONValue(named: "code", from: values, defaultValue: 0)
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        self.DataDic = getJSONValue(named: "DataDic", from: values, defaultValue: [:])
    }
    
    /**
     
     */
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:"DataEvent",
            "evtSRtime": self.evtSRtime,
            "evtClassName": "DataEvent",
            "code": code,
            "appKey": appKey,
            "DataDic": DataDic
        ]
    }
}
