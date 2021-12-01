//
//  Encrypt.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/30.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation
import CryptoSwift

public struct EncryptUtils {
    public static func fusionString(base64str: String, filter: String, textset64: String) -> String
    {
        let nums = [157, 233, 227, 179, 41, 257, 31, 89, 59, 83, 109, 3, 107, 5, 241, 269, 281, 139, 211, 23, 127, 131, 223, 97, 199, 163, 277, 29, 73, 11, 193, 151, 79, 19, 7, 229, 167, 47, 197, 149, 103, 37, 239, 13, 113, 2, 53, 61, 137, 263]
        let nB = base64str.count
        if( nB < 1 ){
            return ""
        }
        
        let nF = filter.count
        let textset = textset64.data(using: .ascii)!.map{ Int($0) }
        let filterset = filter.data(using: .ascii)!.map{ Int($0) }
        var ret = base64str.data(using: .ascii)!.map{ Int($0) }
        
        var offset = 0
        for i in (0..<(max(nB, nF))).reversed() {
            let c0 = ret[i % nB]
            let f = filterset[i % nF]
            let n = nums[(i + offset) % nums.count]
            let index = textset.firstIndex(of: c0)! + f + n
            let c = textset[index % textset64.count]
            ret[i % nB] = c
            offset = offset + 1
        }
        return String(data: Data(ret.map{ UInt8($0) }), encoding: .ascii)!
    }
    
    public static func encrypt(key: String, iv: String, target:String) -> String? {
        do {
            let aes = try AES(key: key, iv: iv)
            let cipherArray = try aes.encrypt(Array(target.utf8))
            let data = NSData(bytes: cipherArray, length: cipherArray.count)
            let base64Data = data.base64EncodedData(options: [])
            let base64String = String(data: base64Data as Data, encoding: String.Encoding.utf8)
            return base64String
        }
        catch {
            return nil
        }
    }
    
    public static func decrypt(key: String, iv: String, base64:String) -> String? {
        do {
            let aes = try AES(key: key, iv: iv)
            let aData = base64.data(using: String.Encoding.utf8)! as Data
            let dData = NSData(base64Encoded: aData, options: [])
            guard let data = dData else {
                return nil
            }
            var aBuffer = Array<UInt8>(repeating: 0, count: data.length)
            data.getBytes(&aBuffer, length: data.length)
            
            let decrypted = try aes.decrypt(aBuffer)
            let string = String(data: Data(bytes: decrypted), encoding: .utf8)
            return string
            
        }
        catch {
            return nil
        }
    }
}
