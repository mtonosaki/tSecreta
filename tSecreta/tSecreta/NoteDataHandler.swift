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

public enum ImageHashMode {
    case GRAY1
    case RGB3
}

// Calculate hash code of an image implemented based on below source code.
// see also https://github.com/coenm/ImageHash/blob/develop/src/ImageHash/HashAlgorithms/AverageHash.cs
private func getImageHash(mode: ImageHashMode, image: UIImage, defaultHash: String) -> String {

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
    
    var hashStr = ""
    for channel in (mode == .RGB3 ? 1 : 0)..<(1 + (mode == .RGB3 ? 3 : 0)){
        var mask = UInt64(1) << (WH - 1)
        var averageValue: UInt64 = 0
        var hashCode: UInt64 = 0
        for y in 0..<H {
            for x in 0..<W {
                let pos = cgImage.bytesPerRow * y + x * (cgImage.bitsPerPixel / 8)
                switch channel {
                    case 1:
                        averageValue += UInt64(CGFloat(data[pos + 0]))
                    case 2:
                        averageValue += UInt64(CGFloat(data[pos + 1]))
                    case 3:
                        averageValue += UInt64(CGFloat(data[pos + 2]))
                    default:
                        averageValue += UInt64((CGFloat(data[pos + 0]) + CGFloat(data[pos + 1]) + CGFloat(data[pos + 2])) / 3.0)
                }
            }
        }
        averageValue /= UInt64(WH)
        for y in 0..<H {
            for x in 0..<W {
                let pos = cgImage.bytesPerRow * y + x * (cgImage.bitsPerPixel / 8)
                var pixel: UInt64
                switch channel {
                    case 1:
                        pixel = UInt64(CGFloat(data[pos + 0]))
                    case 2:
                        pixel = UInt64(CGFloat(data[pos + 1]))
                    case 3:
                        pixel = UInt64(CGFloat(data[pos + 2]))
                    default:
                        pixel = UInt64((CGFloat(data[pos + 0]) + CGFloat(data[pos + 1]) + CGFloat(data[pos + 2])) / 3.0)
                }
                if pixel >= averageValue {
                    hashCode |= mask
                }
                mask >>= 1
            }
        }

        let hashData = Data(bytes: &hashCode, count: MemoryLayout<UInt64>.size)
        let hashStr0 = hashData.map {
            byte in
            return String(NSString(format:"%02x", byte))
        }.joined()
        hashStr += hashStr0
        if channel > 0 && channel < 3 {
            hashStr += "-"
        }
    }
    return hashStr
}

public func saveLogoPicture(image: UIImage, defaultName: String?, note: Note) async -> String? {
    
    guard let data = image.pngData() else {
        return "Cannot got logo image data."
    }
    let hash = getImageHash(mode: .RGB3, image: image, defaultHash: defaultName ?? "no-name")
    let filename = "logo-\(hash).png"
    let message = await saveLogoPicture(imageData: data, filename: filename, note: note)
    return message
}


public func saveLogoPicture(imageData: Data, filename: String, note: Note) async -> String? {
    guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) else {
        return "Cannot got logo url"
    }
    print("saving logo image \(url)")
    
    do {
        try imageData.write(to: url)
        note.setValueNoHistory(field: .logoFilename, text: filename)
        return nil
    }
    catch let error {
        return error.localizedDescription
    }
}

