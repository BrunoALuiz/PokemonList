//
//  Pokemon.swift
//  PokemonList
//
//  Created by Bruno Luiz on 06/07/18.
//  Copyright © 2018 Bruno Luiz. All rights reserved.
//

import Foundation
import SwiftyJSON

class PokemonResult: NSObject {

    var url: String?
    var name: String?
    
    init(json: JSON) {
        self.url = json["url"].string
        self.name = json["name"].string
    }

}
