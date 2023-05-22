//
//  CasePropertiesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import UIKit

protocol CaseTitleCellDelegate: AnyObject {
    func didUpdateTitle(_ text: String)
}

class CaseTitleCell: UICollectionViewCell {
    
    weak var delegate: CaseTitleCellDelegate?
    
    private var detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: METextField = {
        let tf = METextField(placeholder: "Title", withSpacer: false)
        tf.delegate = self
        tf.tintColor = primaryColor
        tf.keyboardType = .default
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private var titleTextTracker = CharacterTextTracker(withMaxCharacters: 130)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func configure() {
        addSubviews(detailsLabel, titleTextField, titleTextTracker, separatorView)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            detailsLabel.bottomAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -2),
            detailsLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            titleTextTracker.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            titleTextTracker.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            titleTextTracker.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            titleTextTracker.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        titleTextTracker.isHidden = true
    }

    @objc func textDidChange() {
        guard let text = titleTextField.text else { return }
        let count = text.count
        
        if count != 0 {
            detailsLabel.isHidden = false
        } else {
            detailsLabel.isHidden = true
        }
        
        if count > 130 {
            titleTextField.deleteBackward()
            return
        }
        
        delegate?.didUpdateTitle(text)
        titleTextTracker.updateTextTracking(toValue: count)
    }
}

extension CaseTitleCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextTracker.isHidden = false
        delegate?.didUpdateTitle(textField.text ?? "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextTracker.isHidden = true
    }
}

