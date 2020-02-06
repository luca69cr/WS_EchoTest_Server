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


/// Handle specific application requested with route methodology
let ApplicationRouteHandler: Route? = Route(method: .get, uri: "/application", handler: {
     request, response in
     
     /// To add a WebSocket service, set the handler to WebSocketHandler.
     /// Provide your closure which will return your service handler.
     WebSocketHandler(handlerProducer: {
         (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
         
         /// Check to make sure the client is requesting our "echo" service.
         /// at this poni validate application domain for use consistent application manager subscription
         guard !protocols.contains("") else {
             return nil
         }
         
         print("con socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
         
         
         
         // Return our service handler.
         return ApplicationHandler(ApplicationsName: protocols)
     }).handleRequest(request: request, response: response)
 })

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
    var socketProtocol: String?
    private var ClassName: String = ""
    private var InvalidProtocols: Bool = false
     var AppSocket: WebSocket?
    private var SocketKey: String?
    
    struct AppRow {
        var Name: String
        var Object: Application
    }
    var AppClassInstances: [AppRow] = []
    var AppInstanceSelected: Application = Application() ///initialized with standar Application class
    
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
            let ServiceClass: AnyClass? =  NSClassFromString(NameOfClass) //as! ApplicationService.Type
            if (ServiceClass != nil){
                let DynamicAppClass = ServiceClass as! Application.Type
                let Instance = DynamicAppClass.init(caller: self)
                let AppObject: AppRow = AppRow(Name:AppName, Object: Instance)
                AppClassInstances.append(AppObject)
            } else {
                Log.debug(message: "Invalid Application Classes: \(NameOfClass)")
            }
        }
        /// any match of  service class, is same of empty protocol array
        if AppClassInstances.isEmpty==true {
            InvalidProtocols = true
            socketProtocol=""
            //self.AppInstanceSelected=nil
        }else {
            /// - ToDoo: insert a complex logic for choice te Application
            socketProtocol = AppClassInstances[0].Name
            AppInstanceSelected = AppClassInstances[0].Object
        }
    }
    
    /**
    The name of the super-protocol we implement. Overrided for perform Application defined algoritm
     
    It should match whatever the client-side WebSocket is initialized with.
    This function is called by the WebSocketHandler once the connection has been established.
    */
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        
        /// Set the socket protocol for convenient use when sochet are realy handled
        AppSocket = socket
        /// Set for non nil key only when sochet are realy handled
        SocketKey = request.header(.custom(name: "sec-websocket-key"))
        ///used for recurse reading when message are sent
        AppInstanceSelected.CurrentRequest = request
        
        /// Check if init evaluate an invalid protocol array
        if InvalidProtocols {
            Log.debug(message: "Invalid Socket Protocols on SocketKey: \(String(describing: SocketKey))")
            socket.close()
            return
        }
        
        
        // Read a message from the client as a String.
        // Alternatively we could call `WebSocket.readBytesMessage` to get binary data from the client.
        
        self.AppInstanceSelected.readMessage()
            
            //Log.debug(message:  "msg socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
            //print("msg socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
            // Print some information to the console for informational purposes.
            //Log.debug(message: "Read msg: \(string) op: \(op) fin: \(fin)")
            //print("Read msg: \(string) op: \(op) fin: \(fin)")
            
            // Echo the data we received back to the client.
            // Pass true for final. This will usually be the case, but WebSockets has the concept of fragmented messages.
            // For example, if one were streaming a large file such as a video, one would pass false for final.
            // This indicates to the receiver that there is more data to come in subsequent messages but that all the data is part of the same logical message.
            // In such a scenario one would pass true for final only on the last bit of the video.
            //socket.sendStringMessage(string: string, final: true) {
                /// This callback is called once the message has been sent.
                /// Recurse to read and echo new message.
             //   self.handleSession(request: request, socket: socket)
            //}
        //}
    }
}

/**
 
 
 */
class Application{
    private var apphandler:ApplicationHandler?
    var CurrentRequest:HTTPRequest?
    
    /**
     */
    required init(){
        //apphandler=NSNull
    }
    /// only used for forcing instance cration
    required init(caller:ApplicationHandler){
        apphandler=caller
    }
    
    /**
     
     */
    func readMessage()  {
        
        if apphandler != nil{
            if ((apphandler?.AppSocket) != nil) {
                apphandler?.AppSocket?.readStringMessage {
                    /// This callback is provided:
                    ///     the received data
                    ///     the message's op-code
                    ///     a boolean indicating if the message is complete (as opposed to fragmented)
                    string, op, fin in
            
                    /// The data parameter might be nil here if either a timeout or a network error, such as the client disconnecting, occurred.
                    /// By default there is no timeout.
                    guard let string = string else {
                        /// This block will be executed if, for example, the browser window is closed.
                        self.apphandler?.AppSocket?.close()
                        return
                    }
                    self.onMessage(message: string, type: op, final: fin)
                }
            }
        }
    }
            
            //Log.debug(message:  "msg socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
            //print("msg socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
            // Print some information to the console for informational purposes.
            //Log.debug(message: "Read msg: \(string) op: \(op) fin: \(fin)")
            //print("Read msg: \(string) op: \(op) fin: \(fin)")
            
            // Echo the data we received back to the client.
            // Pass true for final. This will usually be the case, but WebSockets has the concept of fragmented messages.
            // For example, if one were streaming a large file such as a video, one would pass false for final.
            // This indicates to the receiver that there is more data to come in subsequent messages but that all the data is part of the same logical message.
            // In such a scenario one would pass true for final only on the last bit of the video.
            //socket.sendStringMessage(string: string, final: true) {
                /// This callback is called once the message has been sent.
                /// Recurse to read and echo new message.
             //   self.handleSession(request: request, socket: socket)
            //}
        //}
        
    //}
    
    /**
    
    */
    func sendMessage(message: String, final: Bool){
        if apphandler != nil{
            if ((apphandler?.AppSocket) != nil) {
                apphandler?.AppSocket?.sendStringMessage(string: message, final: final) {
                    /// This callback is called once the message has been sent.
                    /// Recurse to read and echo new message.
                    self.apphandler!.handleSession(request: self.CurrentRequest!, socket: self.apphandler!.AppSocket!)
                }
            }
        }
    }
    
    
    func onMessage(message: String,  type: WebSocket.OpcodeType, final: Bool){}
    
    /**
     
     */
    
}

class Echo: Application {

    override func onMessage(message: String,  type: WebSocket.OpcodeType, final: Bool){
        sendMessage(message: message, final:true)
    }
    
}
