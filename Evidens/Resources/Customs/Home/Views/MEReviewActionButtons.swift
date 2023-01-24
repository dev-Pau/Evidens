//
//  MEReviewActionButtons.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/1/23.
//
import UIKit

protocol MEReviewActionButtonsDelegate: AnyObject {
    func didTapApprove()
    func didTapDelete()
}

class MEReviewActionButtons: UIView {
    
    weak var delegate: MEReviewActionButtonsDelegate?

    lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.tintAdjustmentMode = .normal
        
        var container = AttributeContainer()
      
        container.font = .systemFont(ofSize: 15, weight: .semibold)

        button.configuration?.attributedTitle = AttributedString("Approve", attributes: container)
        
        button.configuration?.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        
        button.configuration?.imagePadding = 10
        
        button.addTarget(self, action: #selector(handleApprove), for: .touchUpInside)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .secondaryLabel
        var container = AttributeContainer()
        button.tintAdjustmentMode = .normal
        container.font = .systemFont(ofSize: 15, weight: .semibold)

        button.configuration?.attributedTitle = AttributedString("Delete", attributes: container)
        
        button.configuration?.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        
        button.configuration?.imagePadding = 10
        return button
    }()
    
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        
        addSubviews(topSeparatorView, deleteButton, acceptButton, separatorView)
        
        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: topAnchor),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            deleteButton.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            //acceptButton.widthAnchor.constraint(equalToConstant: 25),
            deleteButton.heightAnchor.constraint(equalToConstant: 25),
           
            acceptButton.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 5),
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            acceptButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            //acceptButton.widthAnchor.constraint(equalToConstant: 25),
            acceptButton.heightAnchor.constraint(equalToConstant: 25),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    
    @objc func handleApprove() {
        delegate?.didTapApprove()
    }
    
    @objc func handleDelete() {
        print("first tap delete")
        delegate?.didTapDelete()
    }
}
