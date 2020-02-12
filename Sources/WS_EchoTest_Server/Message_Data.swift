//
//  Message_Data.swift
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
 class Message_Data: Message {
    
    static let registerName = "Message_Data"
    /// var msgClass: String
    /// is a server timestamp for message send or received
    /// msgServerTime: Int64
    /// msgCode: String
    final private var appKey: String = ""
    final var DataDic=Dictionary<String, Any>()
    
    override init(){
        super.init()
        msgClass = Message_Signal.registerName
    }
    
    init(code: String, key: String, data: Dictionary<String, Any>) {
        super.init(code: code)
        msgClass = Message_Signal.registerName
        appKey = key
        DataDic = data
    }
    
    /**
     
     */
    final override func setJSONValues(_ values: [String : Any]) {
        self.msgClass = getJSONValue(named: "msgClass", from: values, defaultValue: "")
        self.msgCode = getJSONValue(named: "msgCode", from: values, defaultValue: "")
        self.appKey = getJSONValue(named: "appKey", from: values, defaultValue: "")
        self.DataDic = getJSONValue(named: "DataDic", from: values, defaultValue: [:])
    }
    
    /**
     
     */
    final override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:Message_Data.registerName,
            "msgServerTime": self.msgServerTime,
            "msgClass": self.msgClass,
            "msgCode": self.msgCode,
            "appKey": self.appKey,
            "DataDic": self.DataDic
        ]
    }
}
