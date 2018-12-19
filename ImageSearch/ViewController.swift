//
//  ViewController.swift
//  ImageSearch
//
//  Created by Hayoung Park on 18/12/2018.
//  Copyright © 2018 Hayoung Park. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper

let KAKAO_KEY = "KakaoAK 5248092dcdec8c23d39acfbc500df2d3"

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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJson(query: "설현")
    }
    
    func getJson(query: String) {
        let headers: HTTPHeaders = ["Authorization": KAKAO_KEY]
        let parameters: Parameters = ["query": query]
        
        Alamofire.request("https://dapi.kakao.com/v2/search/image", method: .get, parameters: parameters, headers: headers).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any], let documents = json["documents"] as? [Any] else { return }

            do {
                let mappedDocuments = try documents.map { (docu: Any) -> Document in
                    let data = try JSONSerialization.data(withJSONObject: docu, options: .prettyPrinted)
                    if let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                        return Mapper<Document>().map(JSONString: jsonString) ?? Document(JSONString: "default")!
                    } else {
                        return Document(JSONString: "default")!
                    }
                }
            } catch {
                print("error")
            }
        }
    }
}

