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
    
     func _DispatchMessage(message: Event) {
        do {
            //let eventClass = getJSONValue(named: "appKey", from: values, defaultValue: "")
            let name = message.evtClass
            self.onMessage(message: message)
            return
        } catch {return}
        
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
    func onMessage(message: Event){return}
}


/**
 
 */
class Echo: Application {

    override func onMessage(message: Event) {

        ///Implement echo service
        let appmsg = message as? ApplicationMessage
        appmsg!.appMsg = "echo"
        //message.appDataDic = ["data": "pippo"]
        self.appChannel?.sendMessage(message: appmsg!, multipart: false)
       
        /// return on read state
        self.appChannel?.readMessage()
    }
    
    override func onConnected() {
        Log.debug(message: "App:\(appKey) is Connected")
    }
    
    override func onDisconnected() {
        Log.debug(message: "App:\(appKey) is Disconnected")
    }
}
