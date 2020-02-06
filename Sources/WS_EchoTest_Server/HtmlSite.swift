//
//  File.swift
//  WS_EchoTest_Server
//
//  Created by Luca MURATORE on 06/02/2020.
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


let HtmRouteHandler: Route? = Route(method: .get, uri: "*", handler: { request, response in
    /// manage the different path to local dev and docker container
    #if os(Linux)
        StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest(request: request, response: response)
    #else
        StaticFileHandler(documentRoot: "~/Documents/develop/mintycode/server/server-app/swift/perfect/example/WS_EchoTest_Server/webroot", allowResponseFilters: true).handleRequest(request: request, response: response)
    #endif
})
