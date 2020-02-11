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
    }
    
    /**
     
     */
    func _ConnectedTo(channel: ApplicationHandler){
        appChannel = channel
        self.onConnected()
    }
    
    /**
     
     */
    func _Disconnected(){
        appChannel = nil
        self.onDisconnected()
    }
    
     func _DispatchMessage(message: String) {
        var decodedEvent:Event
        var decodedSignal:SignalEvent
        var decodeDataEvent:DataEvent
        
        JSONDecoding.registerJSONDecodable(name: DataEvent.registerName, creator: { return DataEvent() })
        JSONDecoding.registerJSONDecodable(name: SignalEvent.registerName, creator: { return SignalEvent() })
        do {decodedEvent = try message.jsonDecode() as! Event  }catch{return}
        switch decodedEvent.evtClassName {
            ///proces the event with specific event type
        case "Event":
            Log.debug(message: "App:\(appKey) message:\(decodedEvent.evtClassName) Warning")
        case "SignalEvent":
            do { decodedSignal = try message.jsonDecode() as! SignalEvent}catch {return}
            self.onSignal(message: decodedSignal)
        case "DataEvent":
            //do { decodeDataEvent = try message.jsonDecode() as! DataEvent} catch {return}
            self.onData(message: decodedEvent as! DataEvent)
        default:
            Log.debug(message: "App:\(appKey) message:\(decodedEvent.evtClassName) is Invalid")
        }
        /// return on read state
        self.appChannel?.readMessage()
    }
    
    /**
     
     */
    
    func Cache() {
        
    }
    
    /**
     
     */
    func Resume() {
        
    }
    
    /**
     
     */
    func onConnected(){return}
    func onDisconnected() {return}
    func onSignal(message: SignalEvent) {return}
    func onData(message: DataEvent){return}
}


/**
 
 */
class Echo: Application {
    enum DataEventCode:  UInt8 {
        case INVALID = 0x00
        case NONAME = 0x01
        case ECHO = 0x02
    }
    override func onData(message: DataEvent) {
        
        ///Implement echo service
        //let appmsg = message as? ApplicationMessage
        message.code = DataEventCode.ECHO.rawValue
        //message.appDataDic = ["data": "pippo"]
        //let msgToSend = message as DataEvent
        do {
            let jsonMsg = try message.jsonEncodedString()
            self.appChannel?.sendMessage(message: jsonMsg, multipart: false)
        }catch{return}

    }
    
    override func onConnected() {
        Log.debug(message: "App:\(appKey) is Connected")
    }
    
    override func onDisconnected() {
        Log.debug(message: "App:\(appKey) is Disconnected")
    }
}
