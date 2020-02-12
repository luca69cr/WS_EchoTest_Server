//
//  Application.swift
//  
//
//  Created by Luca MURATORE on 03/02/2020.
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif
import Foundation

import PerfectLib
import PerfectWebSockets
import PerfectHTTP


/**
 
 
 */
class Application{
    var appChannel: ApplicationHandler?
    let appKey: String = UUID().uuidString
    enum SignalEventCode:  UInt8 {
        case INVALID = 0x00
        case NONAME = 0x01
        case HELLO = 0x02
    }
    /**
     
     */
    required init(){
        appChannel = nil
        JSONDecoding.registerJSONDecodable(name: Message_Signal.registerName, creator: { return Message_Signal() })
        JSONDecoding.registerJSONDecodable(name: Message_Data.registerName, creator: { return Message_Data() })
        RegisterMessageJSONDecodable()
    }
    
    /**
     
     */
    final func _ConnectedTo(channel: ApplicationHandler){
        appChannel = channel
        self.onConnected()
    }
    
    /**
     
     */
    final func _Disconnected(){
        appChannel = nil
        self.onDisconnected()
    }
    
    final func _DispatchMessage(message: String) {
        var decodedEvent:Message = Message()
        
        do { decodedEvent = try message.jsonDecode() as! Message  }catch{return}
        
        ///proces the event with specific meaage format
        switch decodedEvent.msgClass {
        case "Message":
            Log.debug(message: "App:\(appKey) message:\(decodedEvent.msgClass) Warning")
        case "Message_Signal":
            self.onSignal(message: decodedEvent as! Message_Signal)
        case "Message_Data":  
            self.onData(message: decodedEvent as! Message_Data)
        default:
            Log.debug(message: "App:\(appKey) message:\(decodedEvent.msgClass) is Invalid")
        }
        /// return on read state
        self.appChannel?.readMessage() ///todo: probabily move this on single onMessage
    }
    
    
    func HandShake(){
        
    }
    
    
    
    /**
     
     */
    
    final func Cache() {
        
    }
    
    /**
     
     */
    final func Resume() {
        
    }
    
    /**
     this a overridable function for your specific Application Class
     */
    func RegisterMessageJSONDecodable(){return}
    func onConnected(){return}
    func onDisconnected() {return}
    func onSignal(message: Message_Signal) {return}
    func onData(message: Message_Data){return}
}


/**
 
 */
class Echo: Application {
    
    override func onData(message: Message_Data) {
        
        enum evtCode: String {
            case INVALID = "INVALID"
            case NONAME = "NONAME"
            case SENDTOECHO = "SENDTOECHO"
            case ECHO = "ECHO"
        }
        
        
        switch message.msgCode {
        case evtCode.SENDTOECHO.rawValue :
            ///Implement echo service
            let repmessage = Message_Data(code: evtCode.ECHO.rawValue,key: appKey, data: message.DataDic)
            //message.msgCode = evtCode.ECHO.rawValue
            do {
                let jsonMsg = try repmessage.jsonEncodedString()
                self.appChannel?.sendMessage(message: jsonMsg, multipart: false)
            }catch{return}
        default:
            return
        }
    }
    
    override func onConnected() {
        let message: Message_Data = Message_Data(code: "HELLO", key: self.appKey, data: ["data": "is Connected"])
        //message.appKey = self.appKey
        //message.DataDic = ["data": "is Connected"]
        //message.msgCode = "HELLO"
        
        Log.debug(message: "App:\(appKey) is Connected")
        do {
            let jsonMsg = try message.jsonEncodedString()
            self.appChannel?.sendMessage(message: jsonMsg, multipart: false)
        }catch{return}
    }
    
    override func onDisconnected() {
        Log.debug(message: "App:\(appKey) is Disconnected")
    }
}
