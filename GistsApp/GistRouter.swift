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
    case GetMyStarred()
    
    case GetAtPath(String)
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .GetPublic():
                return .GET
            case .GetMyStarred():
                return .GET
            case .GetAtPath:
                return .GET
            }
        }
        
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .GetPublic:
                return ("/gists/public", nil)
            case .GetMyStarred:
                return ("/gists/starred", nil)
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
        
        if let token = GitHubAPIManager.sharedInstance.OAuthToken {
            URLRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodeRequest, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encodeRequest.HTTPMethod = method.rawValue
        
        return encodeRequest
        
    }
    

    
    
    
    
        
}