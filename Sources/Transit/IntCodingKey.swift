//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/22/22.
//

import Foundation

struct IntCodingKey: CodingKey {
    init?(intValue: Int) {
        self.int = intValue
    }

    var stringValue: String {
        int.description
    }

    init?(stringValue: String) {
        if let value = Int(stringValue) {
            self.int = value
        } else {
            return nil
        }
    }

    var intValue: Int? {
        int
    }

    let int: Int

}
