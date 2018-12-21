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

func MainScreen() -> CGSize {
    return UIScreen.main.bounds.size
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var searchBar: UISearchBar!
    var searchBar: UISearchBar!
    
    var searchResults: [Document] = [] {
        didSet {
            print("didset")
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: MainScreen().width, height: 50))
        self.searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        
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
                    return Mapper<Document>().map(JSONString: String(data: data, encoding: String.Encoding.utf8) ?? "") ?? Document(JSONString: "default")!
                }
                self.searchResults = mappedDocuments
                
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
        let imageRatio = CGFloat(document.height) / CGFloat(document.width)
        
        return (MainScreen().width * imageRatio) / 2
    }
}

extension ViewController: UISearchBarDelegate {
    
}
