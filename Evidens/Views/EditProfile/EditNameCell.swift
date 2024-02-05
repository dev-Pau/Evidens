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
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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
        backgroundColor = .systemBackground
        addSubviews(titleLabel, firstNameTextField, separatorView)
        
        let width: CGFloat = UIDevice.isPad ? 150 : 100
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalToConstant: width),
            
            firstNameTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            firstNameTextField.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            firstNameTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            firstNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    func set(title: String, placeholder: String, name: String) {
        titleLabel.text = title
        firstNameTextField.text = name
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: primaryGray])
        firstNameTextField.placeholder = placeholder
    }
    
    func set(text: String) {
        firstNameTextField.text = text
    }
    
    func disableTextField() {
        firstNameTextField.isUserInteractionEnabled = false
    }
    
    @objc func textDidChange() {
        guard let text = firstNameTextField.text else { return }
        delegate?.textDidChange(self, text: text)
    }
}
