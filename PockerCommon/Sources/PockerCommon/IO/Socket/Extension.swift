//
//  Extension.swift
//  
//
//  Created by Wttch on 2023/4/9.
//

import Foundation

extension UInt32 {
    func toData() -> Data {
        return Data([
            UInt8(truncatingIfNeeded: self >> 24),
            UInt8(truncatingIfNeeded: self >> 16),
            UInt8(truncatingIfNeeded: self >> 8),
            UInt8(truncatingIfNeeded: self)
        ])
    }
}

extension Data {
    func toUInt32() -> UInt32 {
        let tmp = [UInt8](self)
        var ret : UInt32 = 0
        for i in 0..<4 {
            ret <<= 8
            ret |= UInt32(tmp[i] & 0xFF)
        }
        return ret
    }
    
    func toInt() -> Int {
        return Int(toUInt32())
    }
}
