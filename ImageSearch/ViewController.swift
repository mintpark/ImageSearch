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

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults: [Document] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        getJson(query: "설현")
    }
    
    func getJson(query: String) {
        let headers: HTTPHeaders = ["Authorization": KAKAO_KEY]
        let parameters: Parameters = ["query": query, "size": 10]
        
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
                self.searchResults = mappedDocuments
                self.tableView.reloadData()
                
            } catch {
                print("error")
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        cell.document = searchResults[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let document = searchResults[indexPath.row]
        let imageRatio = document.height / document.width
        
//        return CGFloat(document.width * imageRatio)
        return 100
    }
}
