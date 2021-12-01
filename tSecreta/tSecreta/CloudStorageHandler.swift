//
//  CloudStorageHandler.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//

import Foundation
//import AZSClient // No need import AZSClient becaulse of object-c bridge included



public func DownloadAzureBlob(userObjectId: String, callback: @escaping (Bool, String?) ->  Void){
    do {
        let cn = try AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
        let blobClient = cn.getBlobClient()
        let blobContainer = blobClient.containerReference(fromName: "tsecret")
        let blob = blobContainer.blockBlobReference(fromName: "MainData.\(userObjectId).dat")
        blob.downloadToText(){
            (error, text) in
            if let error = error {
                //self.addError(error.localizedDescription)
                callback(false, error.localizedDescription)
                return
            }
            if let base64sec = text {
                //self.addInfo("Downloaded \(base64sec.count) characters")
                callback(true, nil)
            }
        }
    }
    catch let ex {
        //self.addFatal("Azue Error \(ex.localizedDescription)")
    }

}
