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
    
    var OAuthToken: String?
    
    let cid = "123123"
    let cs = "adfasdfas"
    
    
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
    
    func printMyStarredGistsWithOAuth2() -> Void {
        alamofireManager.request(GistRouter.GetMyStarred())
            .responseString { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    return
                }
                if let receivedString = response.result.value {
                    print(receivedString)
                }
                
        }
    }
    
    func hasOAuthToken() -> Bool {
        if let token = self.OAuthToken {
            return !token.isEmpty
        }
        return false
    }
    
    func URLToStartOAuth2Login() -> NSURL? {
        let authPath = "https://github.com/login/oauth/authorize" + "?client_id=\(cid)&scope=gist&state=TEST_STATE"
        guard let authURL: NSURL = NSURL(string: authPath) else {
            return nil
        }
        return authURL
    }
    
    func swapAuthCodeForToken(receivedCode: String) {
        let getTokenPath:String = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": cid, "client_secret": cs, "code": receivedCode]
        let jsonHeader = ["Accept": "application/json"]
        Alamofire.request(.POST, getTokenPath, parameters: tokenParams, headers: jsonHeader)
            .responseString { response in
                if let error = response.result.error {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(false, forKey: "loadingOAuthToken")
                    // TODO: bubble up error
                    print(error)
                    return
                }
                print(response.result.value)
                if let receivedResults = response.result.value, jsonData =
                    receivedResults.dataUsingEncoding(NSUTF8StringEncoding,
                        allowLossyConversion: false) {
                    let jsonResults = JSON(data: jsonData)
                    for (key, value) in jsonResults {
                        switch key {
                        case "access_token":
                            self.OAuthToken = value.string
                            print(self.OAuthToken)
                        case "scope":
                            // TODO: verify scope
                            print("SET SCOPE")
                        case "token_type":
                            // TODO: verify is bearer
                            print("CHECK IF BEARER")
                        default:
                            print("got more than I expected from the OAuth token exchange")
                            print(key)
                        }
                    }
                }
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(false, forKey: "loadingOAuthToken")
                if (self.hasOAuthToken()) {
                    self.printMyStarredGistsWithOAuth2()
                }
        }
    }
    
    func processOAuthStep1Response(url: NSURL) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if (queryItem.name.lowercaseString == "code") {
                    code = queryItem.value
                    break
                }
            }
        }
        if let receivedCode = code {
            swapAuthCodeForToken(receivedCode)
        } else {
            // no code in URL that we launched with
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "loadingOAuthToken")
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