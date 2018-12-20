//
//  Document.swift
//  ImageSearch
//
//  Created by Hayoung Park on 20/12/2018.
//  Copyright © 2018 Hayoung Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct Document: Mappable {
    var collection: String!
    var date: String!
    var height: Int!
    var width: Int!
    var sitename: String!
    var docUrl: String!
    var imageUrl: String!
    var thumbnailUrl: String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        height          <- map["height"]
        thumbnailUrl    <- map["thumbnail_url"]
        date            <- map["datetime"]
        imageUrl        <- map["image_url"]
        collection      <- map["collection"]
        docUrl          <- map["doc_url"]
        width           <- map["width"]
        sitename        <- map["display_sitename"]
    }
}
