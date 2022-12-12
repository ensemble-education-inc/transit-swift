//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

let defaultHandlers: [Handler] = [
    CachingHandler(),
    MapHandler(),
    SetHandler(),
    ScalarHandler(),
    ListHandler(),
    MillisecondsSince1970Handler(),
    ISO8601DateHandler(),
    URIHandler(),
    UUIDHandler(),
]
