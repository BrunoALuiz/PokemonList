//
//  PokemonListProvider.swift
//  PokemonList
//
//  Created by Bruno Luiz on 07/07/18.
//  Copyright © 2018 Bruno Luiz. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class PokemonListProvider: NSObject {
    
    static func getAll(fromOffSet offSet: Int, completion: @escaping (_ result: [PokemonResult], _ isSuccess: Bool,
        _ error: NetworkResponse.Error?) -> Void) {
        
        NetworkService.Pokemon.all(with: 20, from: offSet).execute { (json, response) in
            
            switch response {
            case .success:
                var pokemonResult: [PokemonResult] = []
                
                json["results"].array?.forEach({ (json) in
                    pokemonResult.append(PokemonResult(json: json))
                })
                completion(pokemonResult, true, nil)
                
            case let .error(error):
                completion([], false, error)
            }
            
        }
    }
    
}
