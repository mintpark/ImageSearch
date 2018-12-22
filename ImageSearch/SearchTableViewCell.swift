//
//  SearchTableViewCell.swift
//  ImageSearch
//
//  Created by Hayoung Park on 20/12/2018.
//  Copyright © 2018 Hayoung Park. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    static let identifier = "SearchTableViewCell"
    var document: Document? {
        didSet {
            bindData(document: self.document)
        }
    }
    
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var testLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchImageView.contentMode = .scaleAspectFit
    }
    
    fileprivate func bindData(document: Document?) {
        guard let document = document, let urlStr = document.imageUrl, let url = URL(string: urlStr) else { return }
        testLabel.text = document.sitename
        
        searchImageView.kf.indicatorType = .activity
        searchImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { result in
            switch result {
            case .success(let value):
                break
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
