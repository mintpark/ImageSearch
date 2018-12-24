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

struct SearchViewModel {
    var height: Int
    var width: Int
    var imageUrl: URL
}

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var timer: Timer?
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var page: Int = 1
    
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
            timer?.invalidate()
            
            if searchKeyword != "" {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startSearching), userInfo: nil, repeats: false)
            }
        }
    }
    
    private var searchResults: [SearchViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = 100
        
        searchBar.delegate = self
        searchBar.setShowsCancelButton(true, animated: true)
        
        tableView.addSubview(refreshControl)
    }
    
    @objc fileprivate func refresh(_ refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc fileprivate func startSearching() {
        page = 1
        searchResults = []
        searchActive = false
        fetchSearchData(query: searchKeyword, page: page)
    }
    
    fileprivate func fetchSearchData(query: String, page: Int) {
        let headers: HTTPHeaders = ["Authorization": KAKAO_KEY]
        let parameters: Parameters = ["query": query, "size": 20, "page": page]
        
        Alamofire.request("https://dapi.kakao.com/v2/search/image", method: .get, parameters: parameters, headers: headers).responseJSON { response in
            guard let json = response.result.value as? [String: Any], let documents = json["documents"] as? [Any] else {
                self.messageView.isHidden = false
                self.messageLabel.text = "알 수 없는 에러입니다. \n네트워크 상태를 확인하시고 다시 시도해 주세요."
                self.searchResults = []
                self.tableView.reloadData()
                return
            }
            
            if documents.count == 0 {
                self.messageView.isHidden = false
                self.messageLabel.text = "\(query)에 관한 검색결과가 없습니다."
                return
            }
            
            do {
                self.messageView.isHidden = true
                let mappedDocuments = try documents.compactMap { (docu: Any) -> SearchViewModel? in
                    let data = try JSONSerialization.data(withJSONObject: docu, options: .prettyPrinted)
                    if let item = Mapper<Document>().map(JSONString: String(data: data, encoding: String.Encoding.utf8) ?? ""),
                        let url = URL(string: item.imageUrl) {
                        return SearchViewModel(height: item.height, width: item.width, imageUrl: url)
                    }
                    return nil
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell, indexPath.row < searchResults.count else { return UITableViewCell() }
        cell.viewModel = searchResults[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchResults.count <= indexPath.row { return 0 }
        
        let document = searchResults[indexPath.row]
        let imageRatio = CGFloat(document.height) / CGFloat(document.width)
        
        return (MainScreen().width * imageRatio)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == searchResults.count - 2, searchKeyword != "" {
            page += 1
            fetchSearchData(query: searchKeyword, page: page)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let startIndex = indexPaths.first?.row, let lastIndex = indexPaths.last?.row else { return }
        
        let urls = searchResults.enumerated().compactMap({ (index, searchResult) -> URL? in
            if startIndex <= index, lastIndex >= index {
                return searchResult.imageUrl
            } else {
                return nil
            }
        })
        ImagePrefetcher(urls: urls).start()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startSearching()
    }
}
