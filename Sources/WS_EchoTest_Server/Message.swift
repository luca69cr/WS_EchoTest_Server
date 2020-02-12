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

/*extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}*/


/**
 
 */
class Message: JSONConvertibleObject {
    final var msgClass: String = ""
    /// is a server timestamp for message send or received
    final let msgServerTime: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    final var msgCode:String = ""
    
    override init(){
        super.init()
        msgCode=""
    }
    
    init(code: String){
        super.init()
        msgCode=code
    }
}





