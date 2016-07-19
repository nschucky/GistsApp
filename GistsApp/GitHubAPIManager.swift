//
//  GitHubAPIManager.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/16/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class GitHubAPIManager {
    
    static let sharedInstance = GitHubAPIManager()
    var alamofireManager: Alamofire.Manager
    
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        alamofireManager = Alamofire.Manager(configuration: configuration)
    }
    
    
    func getPublicGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void)  {
        if let urlString = pageToLoad {
            getGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
        } else {
            getGists(GistRouter.GetPublic(), completionHandler: completionHandler)
        }
    }
    
    func getGists(urlRequet: URLRequestConvertible, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
        alamofireManager.request(urlRequet)
        .validate()
        .responseArrayy { (response: Response<[Gist], NSError>) in
                guard response.result.error == nil, let gists = response.result.value else {
                    print(response.result.error)
                    completionHandler(response.result, nil)
                    return
                }
                let next = self.getNextPageHeaders(response.response!)
                completionHandler(.Success(gists), next)
        }
    }
    
    private func getNextPageHeaders(response: NSHTTPURLResponse) -> String? {
        if let linkHeader = response.allHeaderFields["Link"] as? String {
            let components = linkHeader.characters.split { $0 == "," }.map { String($0) }
            for item in components {
                let rangeOfNext = item.rangeOfString("rel=\"next\"", options: [])
                if rangeOfNext != nil {
                    let rangeOfPaddedURL = item.rangeOfString("<(.*)>", options: .RegularExpressionSearch)
                    if let range = rangeOfPaddedURL {
                        let nextURL = item.substringWithRange(range)
                        let startIndex = nextURL.startIndex.advancedBy(1)
                        let endIndex = nextURL.endIndex.advancedBy(-1)
                        let urlRande = startIndex..<endIndex
                        return nextURL.substringWithRange(urlRande)
                    }
                    
                }
            }
        }
        return nil
    }
    
    func imageFromURLString(imageURLString: String, completionHandler: (UIImage?, NSError?) -> Void) {
        alamofireManager.request(.GET, imageURLString)
            .response { (request, response, data, error) in
                
                if data == nil {
                    completionHandler(nil, error)
                    return
                }
                
                let image = UIImage(data: data! as NSData)
                completionHandler(image, nil)
                
            }
    }
}