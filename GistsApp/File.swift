//
//  File.swift
//  GistsApp
//
//  Created by Antonio Alves on 8/2/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation
import SwiftyJSON

class File: ResponseJSONObjectSerializabl {
    var filename: String?
    var raw_url: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.filename = json["filename"].string
        self.raw_url = json["raw_url"].string
    }
}

