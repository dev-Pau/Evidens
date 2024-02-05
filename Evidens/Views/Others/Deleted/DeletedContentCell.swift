//
//  DeletedContentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/8/23.
//

import UIKit

protocol DeletedContentCellDelegate: AnyObject {
    func didTapContentLearnMore()
}

class DeletedContentCell: UICollectionViewCell {
    
    weak var delegate: DeletedContentCellDelegate?

    private let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7
        view.layer.borderWidth = 0.4
        view.layer.borderColor = separatorColor.cgColor
        view.backgroundColor = .quaternarySystemFill.withAlphaComponent(0.1)
        return view
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryGray
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var help: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.textColor = primaryColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeMore)))
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private func configure() {
        addSubviews(bgView, title, help, separatorView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bgView.bottomAnchor.constraint(equalTo: help.bottomAnchor, constant: 10),

            title.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10),
            
            help.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),
            help.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            help.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            help.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        title.text = AppStrings.Content.Comment.delete
        help.text = AppStrings.Content.Empty.learn
    }
    
    func setPost() {
        title.text = AppStrings.Content.Post.deleted
        help.text = AppStrings.Content.Empty.learn
    }
    
    func setCase() {
        title.text = AppStrings.Content.Case.deleted
        help.text = AppStrings.Content.Empty.learn
    }
    
    @objc func handleSeeMore() {
        delegate?.didTapContentLearnMore()
    }
}

