//
//  ResponseJSONObjectSerializable.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/16/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol ResponseJSONObjectSerializabl {
    init?(json: SwiftyJSON.JSON)
}

