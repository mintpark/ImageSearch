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
    var viewModel: SearchViewModel? {
        didSet {
            bind(viewModel: self.viewModel)
        }
    }
    
    @IBOutlet weak var searchImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchImageView.contentMode = .scaleAspectFit
    }
    
    fileprivate func bind(viewModel: SearchViewModel?) {
        guard let viewModel = viewModel else { return }
        
        searchImageView.kf.indicatorType = .activity
        searchImageView.kf.setImage(with: viewModel.imageUrl, options: [.transition(.fade(0.2))]) { result in
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
