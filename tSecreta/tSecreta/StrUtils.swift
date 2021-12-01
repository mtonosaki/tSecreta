//
//  StrUtils.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//

import Foundation

extension String {
    public func Mid(start: Int, len: Int = 999999999) -> String.SubSequence {
        if start >= self.count {
            return self[self.endIndex..<self.endIndex]
        }
        var safeStart: Int = start
        var safeLen: Int = len
        if start < 0 {
            safeLen = safeLen + start
            safeStart = 0
        }
        if safeStart + safeLen >= self.count {
            safeLen = self.count - safeStart
        }
        let i0 = self.startIndex
        let i1 = self.index(i0, offsetBy: safeStart)
        if safeLen < 1 {
            return self[i1..<i1]
        }
        let i2 = self.index(i1, offsetBy: safeLen)
        return self[i1..<i2]
    }
}
