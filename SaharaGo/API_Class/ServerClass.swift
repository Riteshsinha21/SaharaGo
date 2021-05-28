//
//  ServerClass.swift
//  Amistos
//
//  Created by chawtech solutions on 3/26/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

var appLoginToken : String?

public struct ERNetworkManagerResponse {    /// The server's response to the URL request
    public let responseDict: NSDictionary?
    /// The error encountered while executing or validating the request.
    public let message: String?
    
    /// Status of the request.
    public let success: Bool?
    var _metrics: AnyObject?
    init(response: NSDictionary?, status: Bool?,error: String?) {
        
        self.message = error
        self.responseDict = response
        self.success = status
    }
}

class ServerClass: NSObject {
    var arrRes = [[String:AnyObject]]()
    class var sharedInstance:ServerClass {
        struct Singleton {
            static let instance = ServerClass()
        }
        return Singleton.instance
    }
    
    private static var Manager: Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            TRUST_BASE_URL: .disableEvaluation  
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    func getRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : [String : String] = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":X_API_KEY]
        }
        ServerClass.Manager.request(path, method: .get, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            if response.response?.statusCode == 401 {
               //self.logOutUser()
            }
            switch response.result {
            case .success:
                if let value = response.result.value {
                    successBlock(JSON(value ))
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        }
    }
    
    
    func postRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : [String : String] = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
//            headerField = ["Content-Type":"application/json","X-API-KEY":X_API_KEY]
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY]
        }
        ServerClass.Manager.request(path, method: .post, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            if response.response?.statusCode == 401 {
               //self.logOutUser()
            }
            switch response.result {
            case .success:
                if let value = response.result.value {
                    successBlock(JSON(value ))
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        }
    }
    
    
    func putRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : [String : String] = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) as! String]
            
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":X_API_KEY]
        }
        ServerClass.Manager.request(path, method: .put, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON
            { (response) in
                if response.response?.statusCode == 401 {
                    //self.logOutUser()
                }
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        successBlock(JSON(value ))
                    }
                case .failure(let error):
                    errorBlock(error as NSError)
                }
        }
    }
    
    func deleteRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : [String : String] = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":X_API_KEY]
        }
        ServerClass.Manager.request(path, method: .delete, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    successBlock(JSON(value ))
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        }
    }
    
    func sendMultipartRequestToServer(apiUrlStr:String, imageKeyName:String, imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        let headerField = ["X-API-KEY":X_API_KEY]
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageUrl! , withName: imageKeyName)
        },to:apiUrlStr, method: .post, headers : headerField,
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        successBlock(JSON(value ))
                    }
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        })
    }
    
    func sendImageMultipartRequestToServerWithToken(apiUrlStr:String, imageKeyName:String, imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        let headerField = ["X-API-KEY":X_API_KEY,"APPTOKEN":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageUrl! , withName: imageKeyName)
        },to:apiUrlStr, method: .post, headers : headerField,
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        successBlock(JSON(value ))
                    }
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        })
    }
    
    func sendMultipartRequestToServerPP(apiUrlStr:String, imageKeyName:String, imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : [String : String] = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":X_API_KEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) as! String]
        }
        else {
           // headerField = ["Content-Type":"application/json","X-API-KEY":X_API_KEY]
            headerField = ["X-API-KEY":X_API_KEY]
        }
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageUrl! , withName: imageKeyName)
        },to:apiUrlStr, method: .post, headers : headerField,
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        successBlock(JSON(value ))
                    }
                }
            case .failure(let error):
                errorBlock(error as NSError)
            }
        })
    }
    
    func sendMultipartRequestToServer(urlString:String,fileName:String, sendJson:[String:Any], imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void) {
        if let appToken = UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as? String {
            appLoginToken = appToken
        }
        var headerField = [String : String]()
        if UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == true {
            headerField = ["content-type": "application/json","X-API-KEY": X_API_KEY, "APPTOKEN": appLoginToken ?? " "]
        }
        else {
            headerField  = ["content-type": "application/json","X-API-KEY": X_API_KEY]
        }
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key,value) in sendJson
            {
                multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
            }
            if let imageURl = imageUrl
            {
                multipartFormData.append(imageURl, withName: fileName)
            }
            
        }, to: urlString, method: .post, headers : headerField,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                print(upload.progress)
                upload.responseJSON {  response in
                    if let value = response.result.value {
                        successBlock(JSON(value ))
                    }
                }
            case .failure( let error):
                errorBlock(error as NSError)
            }
        })
    }
    
    func sendMultipartRequestToServerWithMultipleImages(urlString:String, imageKeyName:String, imageUrl:[URL?], successBlock:@escaping ( _ response: JSON)->Void , errorBlock: @escaping ( _ error: NSError) -> Void ){
           var headerField : [String : String] = [:]
           if UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == true {
               headerField = ["content-type": "application/json","X-API-KEY": X_API_KEY, "APPTOKEN": appLoginToken ?? " "]
           }
           else {
               headerField = ["content-type": "application/json","X-API-KEY": X_API_KEY]
           }
           Alamofire.upload(multipartFormData: { multipartFormData in
               
               for img in 0..<imageUrl.count
               {
                   multipartFormData.append(imageUrl[img]! , withName: imageKeyName)
               }
           },to: urlString, method: .post, headers : headerField,
             encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value {
                            successBlock(JSON(value ))
                        }
                    }
                case .failure(let error):
                    errorBlock(error as NSError)
                }
           })
    }
    
//    func sendMultipartRequestWithMultileFiles2(urlString:String,fileNames:[String], _ sendJson:[String:Any], imageUrl:[URL?], successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
//    {
//        var headerField : [String : String] = [:]
//        if UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == true {
//            headerField = ["content-type": "application/json","X-API-KEY": X_API_KEY, "APPTOKEN": appLoginToken ?? " "]
//        }
//        else {
//            headerField = ["content-type": "application/json","X-API-KEY": X_API_KEY]
//        }
//        
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            for (key,value) in sendJson {
//                multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
//            }
//            var index = 0
//            for filePath in imageUrl
//            {
//                if let url = filePath
//                {
//                    multipartFormData.append(url, withName: "\(fileNames[index])[]")
//                }
//                index += 1
//            }
//            
//        }, to: urlString, method: .post, headers : headerField,
//           encodingCompletion: { encodingResult in
//            
//            switch encodingResult {
//            case .success(let upload, _, _):
//                print(upload.progress)
//                upload.responseJSON {  response in
//                    if response.response?.statusCode == 403 {
//                        //self.manageSession()
//                    }
//                    
//                    if let value = response.result.value
//                    {
//                        successBlock(JSON(value ))
//                    }
//                }
//            case .failure( let error):
//                self.logOutUser()
//                errorBlock(error as NSError)
//            }
//        })
//    }
    

    
//    func logOutUser()
//    {
//        UserDefaults.standard.removeObject(forKey: "token")
//        UserDefaults.standard.removeObject(forKey: "type")
//        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
//        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
//        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.CART_ID)
//        isLogin = "no"
//        isSignUp = "no"
//        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
//        UIApplication.shared.delegate!.window!!.rootViewController = viewController
//    }
    
    
}
