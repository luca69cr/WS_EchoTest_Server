//
//  PerfectHandlers.swift
//  WebSockets Server
//
//  Created by Kyle Jessup on 2016-01-06.
//  Copyright PerfectlySoft 2016. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
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
//import Application


func makeRoutes() -> Routes {
	
	var routes = Routes()
    // Add a default route which lets us serve the static index.html file
	routes.add(method: .get, uri: "*", handler: { request, response in
        #if os(Linux)
            StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest(request: request, response: response)
        #else
            StaticFileHandler(documentRoot: "~/Documents/develop/mintycode/server/server-app/swift/perfect/example/WS_EchoTest_Server/webroot", allowResponseFilters: true).handleRequest(request: request, response: response)
        #endif
	})
    
    // Add the endpoint for the WebSocket example system
	routes.add(method: .get, uri: "/applications", handler: {
        request, response in
        
        // To add a WebSocket service, set the handler to WebSocketHandler.
        // Provide your closure which will return your service handler.
        WebSocketHandler(handlerProducer: {
            (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
            
            
            // Check to make sure the client is requesting our "echo" service.
            // at this poni validate application domain for use consistent application manager subscription
            guard protocols.contains("paper.freshmint.it") else {
                return nil
            }
            
            // Return our service handler.
            print("con socketkey: \(String(describing: request.header(.custom(name: "sec-websocket-key"))))")
            
            
            //func stringClassFromString(_ className: String) -> AnyClass! {

          
                /// get namespace
                //let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
                    /// get 'anyClass' with classname and namespace
                //let    cls = NSClassFromString("\(namespace).\(className)")!;
                //let    cls = NSClassFromString("\(className)")!;
                    // return AnyClass!
             
                //return cls
            //}
   
            
            //var ApplicationHandler: AnyObject! = nil
            let ApplicationClass = NSClassFromString("WS_EchoTest_Server.Application1") as! Application.Type
            //var nsobjectype : NSObject.Type = ApplicationClass as NSObject.Type
            let ApplicationHandler: Application = ApplicationClass.init()
            
            // Return our service handler.
            
            return ApplicationHandler
        }).handleRequest(request: request, response: response)
    })
	return routes
}




