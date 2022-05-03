//
//  CloudFileHandler.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
// import AZSClient  // no need to import AZSClient here because of imported with Bridging-Header.h as an object-c bridge

public func UploadText(text: String, userObjectId: String, callback: @escaping (Bool, String?) ->  Void) {
    
    let cn = try? AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
    guard let cn = cn else {
        callback(false, "Azure connection string error")
        return
    }
    let blobClient = cn.getBlobClient()
    let blobContainer = blobClient.containerReference(fromName: "tsecret")
    let blob = blobContainer.blockBlobReference(fromName: "MainData.\(userObjectId).dat")

    blob.upload(fromText: text) {
        (error) in

        if let error = error {
            callback(false, error.localizedDescription)
        } else {
            callback(true, nil)
        }
    }
}

public func DownloadText(userObjectId: String, callback: @escaping (Bool, String?) ->  Void) {
    
    let cn = try? AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
    guard let cn = cn else {
        callback(false, "Azure connection string error")
        return
    }
    let blobClient = cn.getBlobClient()
    let blobContainer = blobClient.containerReference(fromName: "tsecret")
    let blob = blobContainer.blockBlobReference(fromName: "MainData.\(userObjectId).dat")
    blob.downloadToText(){
        (error, text) in

        if let error = error {
            callback(false, error.localizedDescription)
            return
        }
        if let text = text {
            callback(true, text)
        }
    }
}

// Calculate hash code of an image implemented based on below source code.
// see also https://github.com/coenm/ImageHash/blob/develop/src/ImageHash/HashAlgorithms/AverageHash.cs
private func getImageHash(image: UIImage, defaultHash: String) -> String {

    let targetWidth: CGFloat = 8
    let canvasSize = CGSize(width: targetWidth, height: CGFloat(ceil(targetWidth / image.size.width * image.size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
    defer {
        UIGraphicsEndImageContext()
    }
    let alphaFill = UIImage(named: "alphaFill")
    alphaFill?.draw(in: CGRect(origin: .zero, size: canvasSize))
    image.draw(in: CGRect(origin: .zero, size: canvasSize))
    guard let image2 = UIGraphicsGetImageFromCurrentImageContext() else {
        return defaultHash
    }
    guard let cgImage = image2.cgImage else {
        return defaultHash
    }
    guard let cfdata = cgImage.dataProvider.unsafelyUnwrapped.data else {
        return defaultHash
    }
    guard let data = CFDataGetBytePtr(cfdata) else {
        return defaultHash
    }
    let W = Int(cgImage.width)
    let H = Int(cgImage.height)
    let WH = W * H
    var mask = UInt64(1) << (WH - 1)
    var averageValue: UInt64 = 0
    var hashCode: UInt64 = 0
    
    for y in 0..<H {
        for x in 0..<W {
            let pos = cgImage.bytesPerRow * y + x * (cgImage.bitsPerPixel / 8)
            let gray = (CGFloat(data[pos + 0]) + CGFloat(data[pos + 1]) + CGFloat(data[pos + 2])) / 3.0
            averageValue += UInt64(gray)
        }
    }
    averageValue /= UInt64(WH)
    for y in 0..<H {
        for x in 0..<W {
            let pos = cgImage.bytesPerRow * y + x * (cgImage.bitsPerPixel / 8)
            let gray = (CGFloat(data[pos + 0]) + CGFloat(data[pos + 1]) + CGFloat(data[pos + 2])) / 3.0
            let pixel = UInt64(gray)
            if pixel >= averageValue {
                hashCode |= mask
            }
            mask >>= 1
        }
    }

    let hashData = Data(bytes: &hashCode, count: MemoryLayout<UInt64>.size)
    let hashStr = hashData.map {
        byte in
        return String(NSString(format:"%02x", byte))
    }.joined()
    return hashStr
}

public func saveLogoPicture(image: UIImage, defaultName: String?, note: Note) async -> String? {
    
    guard let data = image.pngData() else {
        return "Cannot got logo image data."
    }
    let hash = getImageHash(image: image, defaultHash: defaultName ?? "no-name")
    let filename = "logo-\(hash).png"
    print("saved logo image \(filename)")
    let message = await saveLogoPicture(imageData: data, filename: filename, note: note)
    return message
}


public func saveLogoPicture(imageData: Data, filename: String, note: Note) async -> String? {
    guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) else {
        return "Cannot got logo url"
    }
    
    do {
        try imageData.write(to: url)
        note.setValueNoHistory(field: .logoFilename, text: filename)
        return nil
    }
    catch let error {
        return error.localizedDescription
    }
}

