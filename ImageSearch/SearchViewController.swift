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

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var emptyMessageLabel: UILabel!
    private var timer: Timer?
    
    private var page: Int = 5
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        return refreshCtrl
    }()
    
    private var searchActive: Bool = false {
        didSet {
            searchBar.resignFirstResponder()
        }
    }
    
    private var searchKeyword = "" {
        didSet {
            page = 1
            searchResults = []
            timer?.invalidate()
            
            if searchKeyword != "" {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startSearching), userInfo: nil, repeats: false)
            }
        }
    }
    
    private var searchResults: [Document] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = 100
        
        searchBar.delegate = self
        searchBar.setShowsCancelButton(true, animated: true)
        
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        emptyMessageLabel.text = "이미지 검색을 시작해보세요."
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.textAlignment = .center
        tableView.backgroundView = emptyMessageLabel
        
        tableView.addSubview(refreshControl)
    }
    
    @objc fileprivate func refresh(_ refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc fileprivate func startSearching() {
        searchActive = false
        fetchSearchData(query: searchKeyword, page: page)
    }
    
    fileprivate func fetchSearchData(query: String, page: Int) {
        let headers: HTTPHeaders = ["Authorization": KAKAO_KEY]
        let parameters: Parameters = ["query": query, "size": 20, "page": page]
        
        Alamofire.request("https://dapi.kakao.com/v2/search/image", method: .get, parameters: parameters, headers: headers).responseJSON { response in
            guard let json = response.result.value as? [String: Any], let documents = json["documents"] as? [Any] else {
                if response.response?.statusCode == 500 {
                    self.emptyMessageLabel.text = "\(query)에 관한 검색결과가 없습니다."
                } else {
                    self.emptyMessageLabel.text = "알 수 없는 에러입니다. \n네트워크 상태를 확인하시고 다시 시도해 주세요."
                }
                self.searchResults = []
                self.tableView.reloadData()
                return
            }

            do {
                let mappedDocuments = try documents.map { (docu: Any) -> Document in
                    let data = try JSONSerialization.data(withJSONObject: docu, options: .prettyPrinted)
                    let item = Mapper<Document>().map(JSONString: String(data: data, encoding: String.Encoding.utf8) ?? "") ?? Document(JSONString: "default")!
                    return item
                }
                self.searchResults.append(contentsOf: mappedDocuments)
                self.tableView.reloadData()
                
            } catch {
                print("error")
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == searchResults.count - 2 {
            page += 1
            fetchSearchData(query: searchKeyword, page: page)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let startIndex = indexPaths.first?.row, let lastIndex = indexPaths.last?.row else { return }
        
        let urls = searchResults.enumerated().compactMap({ (index, document) -> URL? in
            if startIndex <= index, lastIndex >= index,
                let urlStr = document.imageUrl, let url = URL(string: urlStr) {
                return url
            } else {
                return nil
            }
        })
        ImagePrefetcher(urls: urls).start()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancle")
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDdiChange")
        searchKeyword = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        startSearching()
    }
}
