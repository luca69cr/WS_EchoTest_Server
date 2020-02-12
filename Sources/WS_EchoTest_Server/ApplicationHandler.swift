//
//  File.swift
//  WS_EchoTest_Server
//
//  Created by Luca MURATORE on 07/02/2020.
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

typealias MsgType = WebSocket.OpcodeType

/**
 A WebSocket service handler must impliment the `WebSocketSessionHandler` protocol.
 This protocol requires the function `handleSession(request: WebRequest, socket: WebSocket)`.
 This function will be called once the WebSocket connection has been established,
 at which point it is safe to begin reading and writing messages.

The initial `WebRequest` object which instigated the session is provided for reference.
 Messages are transmitted through the provided `WebSocket` object.
 Call `WebSocket.sendStringMessage` or `WebSocket.sendBinaryMessage` to send data to the client.
Call `WebSocket.readStringMessage` or `WebSocket.readBinaryMessage` to read data from the client.
 By default, reading will block indefinitely until a message arrives or a network error occurs.
A read timeout can be set with `WebSocket.readTimeoutSeconds`.
 When the session is over call `WebSocket.close()`.
*/
class ApplicationHandler: WebSocketSessionHandler {
    
    //private var ClassName: String = ""
    private var InvalidProtocols: Bool = false
    var socketProtocol: String? ///define existence in WebSocketSessionHandler
    var appSocket: WebSocket?
    var appChannelOpened: Bool = false
    private var appSocketKey: String?
    private var appHttpRequest: HTTPRequest?
    //typealias messageType = WebSocket.OpcodeType
    
    struct appProtocolRow {
        var Name: String
        var Object: Application
    }
    var appProtocols: [appProtocolRow] = []
    //var appProtocolSelected: Application = Application() ///initialized with channel tha is na application handler
    var appProtocolSelected: Application?
    
    /**
    Initialaze the application called by route
     
        -Parameter ServicesName: is an array of possible Application passed in socket protocols
     
    */
    init(ApplicationsName:[String]) {
        /// for convenient string classname
        /// the format of string is "ApllicationProjectName.ClassName"
        if ApplicationsName.isEmpty==true {
            InvalidProtocols = true
            return
        }
        for AppName in ApplicationsName {
            let NameOfClass: String = AppName
            let ServiceClass: AnyClass? =  NSClassFromString(AppName) //as! ApplicationService.Type
            if (ServiceClass != nil){
                let DynamicAppClass = ServiceClass as! Application.Type
                //let appInstance = DynamicAppClass.init(channel: self)
                let appInstance = DynamicAppClass.init()
                let AppObject: appProtocolRow = appProtocolRow(Name:AppName, Object: appInstance)
                appProtocols.append(AppObject)
            } else {
                Log.debug(message: "Invalid Application Classes: \(NameOfClass)")
            }
        }
        /// any match of  service class, is same of empty protocol array
        if appProtocols.isEmpty==true {
            InvalidProtocols = true
            socketProtocol=""
            //self.AppInstanceSelected=nil
        }else {
            /// - ToDoo: insert a complex logic for choice te Application
            socketProtocol = appProtocols[0].Name
            appProtocolSelected = appProtocols[0].Object
            /// release memory used for array
            appProtocols = []
        }
    }
    
    /**
    The name of the super-protocol we implement. Overrided for perform Application defined algoritm
     
    It should match whatever the client-side WebSocket is initialized with.
    This function is called by the WebSocketHandler once the connection has been established.
     The close condition is tested on reading the socket
    */
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        
        
        /// Set the socket protocol for convenient use when sochet are realy handled
        appSocket = socket
        
        /// Set for non nil key only when sochet are realy handled
        appSocketKey = request.header(.custom(name: "sec-websocket-key"))
        
        ///used for recurse reading when message are sent
        //AppInstanceSelected.CurrentRequest = request
        appHttpRequest = request
        
        
        
        /// Check if init evaluate an invalid protocol array
        if InvalidProtocols {
            Log.debug(message: "Invalid Socket Protocols on SocketKey: \(String(describing: appSocketKey))")
            appChannelOpened = false
            socket.close()
            return
        }
        
        /// Check if is in the opening connection time
        if !appChannelOpened  {
            appChannelOpened = true
            //JSONDecoding.registerJSONDecodable(name: "Message", creator: { return Message() })
            self.appProtocolSelected?._ConnectedTo(channel: self)
        }
        
        /// set the socket in reading state.
        // Alternatively we could call `WebSocket.readBytesMessage` to get binary data from the client.
        self.readMessage()
    }
    
    /**
     
     */
    func readMessage () {
        
        guard (self.appSocket != nil) else {
            return
        }
        guard (self.appProtocolSelected != nil) else {
            /// This block will be executed if, for example, the protocol isn't possible
            self.appSocket?.close()
            return
        }
        Log.debug(message: "Read In")
        appSocket?.readStringMessage {
            /// This callback is provided:
            ///     the received data
            ///     the message's op-code
            ///     a boolean indicating if the message is complete (as opposed to fragmented)
            string, op, fin in
        
            /// The data parameter might be nil here if either a timeout or a network error, such as the client disconnecting, occurred.
            /// By default there is no timeout.
            guard string != nil else {
                /// This block will be executed if, for example, the browser window is closed or reloaded.
                self.appProtocolSelected?._Disconnected()
                self.appSocket?.close()
                return
            }
            do{
                //let decoded = try string?.jsonDecode() as? ApplicationMessage
                //self.appProtocolSelected?.onMessage(message: decoded!, type: op, final: fin)
                Log.debug(message: "Read Process")
                self.appProtocolSelected?._DispatchMessage(message: string!)
            }catch {
                return
            }
            
        }
        Log.debug(message: "Read Out")
    }
    
    /**
     
     */
    //func sendMessage (jsonMsg: String, multipart: Bool){
    func sendMessage (message: String, multipart: Bool){
        
        if (self.appSocket != nil)  {
            do {
                
                appSocket?.sendStringMessage (string: message, final: !multipart){
                    /// This callback is called once the message has been sent.
                    /// Recurse to read and echo new message.
                    //self.handleSession(request: self.appHttpRequest!, socket: self.appSocket!)
                }
                
            }catch {
                return
            }
            
            ///Log unexecuted send
            //Log.debug(message: "Read msg: \(string) op: \(op) fin: \(fin)")
            return
        }
    }
}
