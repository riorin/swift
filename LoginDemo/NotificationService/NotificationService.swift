//
//  NotificationService.swift
//  NotificationService
//
//  Created by Bayu Yasaputro on 05/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UserNotifications
import Kingfisher

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            // -------
            let userInfo = request.content.userInfo
            if let imageUrl = userInfo["imageUrl"] as? String, let url = URL(string: imageUrl) {
                
                ImageDownloader.default.downloadImage(with: url, completionHandler: { (_, _, _, data) in
                    
                    if let data = data {
                        
                        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
                            .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString,
                                                    isDirectory: true)
                        
                        do {
                            try FileManager.default.createDirectory(at: directory,
                                                                    withIntermediateDirectories: true,
                                                                    attributes: nil)
                            let fileURL = directory.appendingPathComponent("img.png")
                            try data.write(to: fileURL, options: [])
                            
                            let attachment = try UNNotificationAttachment.init(identifier: "img.png",
                                                                               url: fileURL,
                                                                               options: nil)
                            
                            bestAttemptContent.attachments = [attachment]
                            contentHandler(bestAttemptContent)
                        }
                        catch {
                            contentHandler(bestAttemptContent)
                        }
                    }
                    else {
                        contentHandler(bestAttemptContent)
                    }
                })
            }
            else {
                contentHandler(bestAttemptContent)
            }
            // -----
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
