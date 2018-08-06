//
//  NetworkService.swift
//  PokemonList
//
//  Created by Bruno Luiz on 04/07/18.
//  Copyright © 2018 Bruno Luiz. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//**********************************************************************************************************
//
// MARK: - Definitions -
//
//**********************************************************************************************************

public typealias LogicResult = (NetworkResponse) -> Void
public typealias ServerResult = (JSON, NetworkResponse) -> Void

/**
 Defines how the main server defines its responses.
 Showing up the agreed error codes and messages for each of the known scenarios.
 */
public enum NetworkResponse {
    
    public enum Error: String {
        case unkown = "Internal Server Error"
        case noConnection = "No Connection Available!"
    }
    
    case success
    case error(NetworkResponse.Error)
    
    //**************************************************
    // MARK: - Initializers
    //**************************************************
    
    public init(_ response: HTTPURLResponse?) {
        if let httpResponse = response {
            switch httpResponse.statusCode {
            case 200..<300:
                self = .success
            default:
                self = .error(.unkown)
            }
        } else if NetworkReachabilityManager()?.isReachable == false {
            self = .error(.noConnection)
        } else {
            self = .error(.unkown)
        }
    }
}

//**********************************************************************************************************
//
// MARK: - Type -
//
//**********************************************************************************************************

public enum NetworkService {
    
    case mobile(RESTContract)
    
    public typealias RESTContract = (method: HTTPMethod, path: String)
    
    public struct API {
        static public var mobile: String = API.v2
        static public let v2: String = "https://pokeapi.co/api/v2"
    }
    
    public struct Pokemon {
        static public func all(with limit: Int, from offset: Int) -> NetworkService {
            return .mobile((method: .get, path: "/pokemon/?limit=\(limit)&offset=\(offset)"))
        }
    }
    
    //**************************************************
    // MARK: - Protected Methods
    //**************************************************
    
    private func getHeader() -> HTTPHeaders {
        let headers = Alamofire.SessionManager.defaultHTTPHeaders
        return headers
    }
    
    //**************************************************
    // MARK: - Exposed Methods
    //**************************************************
    
    public var method: HTTPMethod {
        switch self {
        case .mobile(let contract):
            return contract.method
        }
    }
    
    public var path: String {
        switch self {
        case .mobile(let contract):
            return NetworkService.API.mobile + contract.path
        }
    }
    
    /// This method is used to Execute Requests
    ///
    /// - Parameters:
    ///   - aPath: Custom Path for your Request.
    ///   - params: Params of your Request
    ///   - completion: This method produces (JSON, ServerResponse) -> Void
    public func execute(aPath: String? = nil,
                        params: [String: Any]? = nil,
                        completion: @escaping ServerResult) {
        DispatchQueue.global(qos: .background).async {
            
            let method = self.method
            let finalPath = aPath ?? self.path
            let closure = { (_ dataResponse: DataResponse<Any>) in
                
                var json: JSON = [:]
                
                NetworkLogger.logResponse(dataResponse.response, data: dataResponse.data)
                
                switch dataResponse.result {
                case .success(let data):
                    json = JSON(data)
                default:
                    break
                }
                
                completion(json, NetworkResponse(dataResponse.response))
            }
            
            let headers = self.getHeader()
            
            if let request = Alamofire.request(finalPath,
                                               method: method,
                                               parameters: params,
                                               encoding: JSONEncoding.default,
                                               headers: headers).responseJSON(completionHandler: closure).request {
                NetworkLogger.logRequest(request)
            }
        }
    }
}
