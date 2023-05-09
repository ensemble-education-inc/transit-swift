//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

let compactDefaultHandlers: [Handler] = [
    CachingHandler(),
    MapHandler(),
    ArrayHandler(),
    SetHandler(),
    ScalarHandler(),
    ListHandler(),
    MillisecondsSince1970Handler(),
    ISO8601DateHandler(),
    URIHandler(),
    UUIDHandler(),
]

let verboseDefaultHandlers: [Handler] = [
    VerboseDictHandler(),
    ArrayHandler(),
    SetHandler(),
    ScalarHandler(),
    ListHandler(),
    MillisecondsSince1970Handler(),
    ISO8601DateHandler(),
    URIHandler(),
    UUIDHandler(),
]
