//
//  ApplicationRoute.swift
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

/// Handle specific application requested with route methodology
let ApplicationRoute: Route? = Route(method: .get, uri: "/application", handler: {
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
        ///for testing concurrent call on socket when server is busy in http request
         ///sleep(30)
         //print("con socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
         
         /// Return our application service handler.
         return ApplicationHandler(ApplicationsName: protocols)
     }).handleRequest(request: request, response: response)
 })
