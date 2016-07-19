//
//  GistRouter.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/16/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {
    
    static let baseURLString: String = "https://api.github.com"
    
    case GetPublic()
    case GetAtPath(String)
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .GetPublic():
                return .GET
            case .GetAtPath:
                return .GET
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .GetPublic:
                return ("/gists/public", nil)
            case .GetAtPath(let path):
                let url = NSURL(string: path)
                print(url)
                let relativePath = url!.relativePath!
                print(relativePath)
                return (relativePath, nil)
            }
        }()
        
        let URL = NSURL(string: GistRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodeRequest, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encodeRequest.HTTPMethod = method.rawValue
        
        return encodeRequest
        
    }
    

    
    
    
    
        
}