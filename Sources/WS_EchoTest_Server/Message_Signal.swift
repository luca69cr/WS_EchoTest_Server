//
//  SignalFormat.swift
//  WS_EchoTest_Server
//
//  Created by Luca MURATORE on 11/02/2020.
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif
import Foundation

import PerfectLib

/**
 
 */
 class Message_Signal: Message {
    static let registerName = "Message_Signal"
    /// evtClassName: String = "Message"
    /// is a server timestamp for message send or received
    /// evtSRtime: Int64 = is a server timestamp for message send or received from server
    ///var msgcode: Int8 = 0x00
    final private var appKey: String = ""

    override init(){
        super.init()
        msgClass = Message_Signal.registerName
    }
    
    init(code: String, key: String) {
        super.init(code: code)
        msgClass = Message_Signal.registerName
        appKey = key
    }
    
    final override func setJSONValues(_ values: [String : Any]) {
        //self.evtClassName =
        self.msgClass=getJSONValue(named: "msgClass", from: values, defaultValue: "")
        //self.evtSRtime = getJSONValue(named: "evtSRtime", from: values, defaultValue: 0)
        self.msgCode = getJSONValue(named: "msgCode", from: values, defaultValue: "")
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        
    }
    
    final override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:Message_Signal.registerName,
            "msgServerTime": self.msgServerTime,
            "msgClass": self.msgClass,
            "msgCode": self.msgCode,
            "appKey": self.appKey
        ]
    }
}
