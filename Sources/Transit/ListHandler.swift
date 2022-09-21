//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct ListHandler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#list" else {
            return value
        }
        return array[1]
    }
}
