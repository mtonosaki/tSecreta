//
//  CloudFileHandler.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation
// import AZSClient
// no need to import AZSClient here because of imported with Bridging-Header.h as an object-c bridge


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
