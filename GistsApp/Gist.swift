//
//  Gist.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/16/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation
import SwiftyJSON


class Gist: ResponseJSONObjectSerializabl {
    var id: String?
    var description: String?
    var ownerLogin: String?
    var ownerAvatarURL: String?
    var url: String?
    
    var files: [File]?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    class func dateFormatter() -> NSDateFormatter {
        let aDateFormatter = NSDateFormatter()
        aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        aDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        aDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return aDateFormatter
    }
    
    static let sharedDateFormatter = Gist.dateFormatter()
    
    required init(json: JSON) {
        self.description = json["description"].string
        self.id = json["id"].string
        self.ownerLogin = json["owner"]["login"].string
        self.ownerAvatarURL = json["owner"]["avatar_url"].string
        self.url = json["url"].string
        
        self.files = [File]()
        if let filesJSON = json["files"].dictionary {
            for (_, fileJSON) in filesJSON {
                if let newFile = File(json: fileJSON) {
                    self.files?.append(newFile)
                }
            }
        }
        
        let dateFormatter = Gist.sharedDateFormatter
        if let dateString = json["created_at"].string {
            self.createdAt = dateFormatter.dateFromString(dateString)
        }
        if let dateString = json["updated_at"].string {
            self.updatedAt = dateFormatter.dateFromString(dateString)
        }
    }
    
    required init() {
        
    }
    
}