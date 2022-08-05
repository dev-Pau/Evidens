//
//  EditNameCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

protocol EditNameCellDelegate: AnyObject {
    func textDidChange(_ cell: UICollectionViewCell, text: String)
}

class EditNameCell: UICollectionViewCell {
    
    weak var delegate: EditNameCellDelegate?
    
    private let cellContentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
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
    
    private func configure() {
        backgroundColor = .white
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(titleLabel, firstNameTextField, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            firstNameTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            firstNameTextField.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            firstNameTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            firstNameTextField.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -5)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 1))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func set(title: String, placeholder: String, name: String) {
        titleLabel.text = title
        firstNameTextField.text = name
        firstNameTextField.placeholder = placeholder
    }
    
    @objc func textDidChange() {
        guard let text = firstNameTextField.text else { return }
        delegate?.textDidChange(self, text: text)
    }
}
