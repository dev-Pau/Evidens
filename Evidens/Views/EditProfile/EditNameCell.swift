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
        tf.autocapitalizationType = .words
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tf.tintColor = K.Colors.primaryColor
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = K.Colors.separatorColor
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
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Content.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Content.verticalPadding),
            titleLabel.widthAnchor.constraint(equalToConstant: width),
            
            firstNameTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            firstNameTextField.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            firstNameTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: K.Paddings.Content.horizontalPadding),
            firstNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding)
        ])
    }
    
    func set(title: String, placeholder: String, name: String) {
        titleLabel.text = title
        firstNameTextField.text = name
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: K.Colors.primaryGray])
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
