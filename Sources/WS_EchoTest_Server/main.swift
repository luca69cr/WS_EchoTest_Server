//
//  UploadHandler.swift
//  Upload Enumerator
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
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

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

Log.logger = ConsoleLogger()
var Applications:Routes = Routes()
Applications.add(HtmlRouteHandler!)
Applications.add(ApplicationRoute!)

do {
    // Launch the HTTP server on port 8181
    //try HTTPServer.launch(name: "websockets server", port: 8181, routes: makeRoutes(), responseFilters: [(try HTTPFilter.contentCompression(data: [:]),.high)])
    //try HTTPServer.launch(name: "websockets server", port: 8181, routes: makeRoutes())
    try HTTPServer.launch(name: "websockets server", port: 8181, routes: Applications)
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
