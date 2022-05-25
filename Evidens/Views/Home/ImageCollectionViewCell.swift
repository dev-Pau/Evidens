//
//  ImageCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/5/22.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var viewModel: PostImageViewModel? {
        didSet {
            configure()
        }
    }
    
    //MARK: - Properties
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.sd_cancelCurrentImageLoad()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(postImageView)
        postImageView.setDimensions(height: 200, width: 200)
        postImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let viewModel = viewModel else { return }

        postImageView.sd_setImage(with: viewModel.imageToDisplay, placeholderImage: UIImage())
        /*
        do {
        
        let imageData = try Data(contentsOf: viewModel.imageToDisplay)
        let imageToDisplay = UIImage(data: imageData)
        
        guard let imageToDisplay = imageToDisplay else { return }
        var aspectR: CGFloat = 0.0
        aspectR = imageToDisplay.size.width/imageToDisplay.size.height
            self.postImageView.setDimensions(height: self.frame.width/aspectR, width: self.frame.width)
            
        } catch {
            print(error)
        }
        
       */
        
        //postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 1/aspectR)
    }
}
