//
//  InputTextField.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/6/23.
//

import UIKit

class InputTextField: UITextField {
    
    private let lineSpacing: CGFloat = 13.0
    private var eye: Bool = false
    private var eyeImageView: UIImageView!
    private var label: UILabel!
    private var secureTextEntry: Bool
    
    init(placeholder: String, secureTextEntry: Bool, title: String) {
        self.secureTextEntry = secureTextEntry
        super.init(frame: .zero)
        isSecureTextEntry = secureTextEntry
        autocapitalizationType = secureTextEntry ? .none : .sentences
        keyboardType = .default
        textColor = primaryColor
        tintColor = primaryColor
        autocorrectionType = .no
        addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let spacer = UIView()
        translatesAutoresizingMaskIntoConstraints = false
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = separatorColor
        addSubview(spacer)
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = title
        label.alpha = 0
        addSubview(label)
  
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            spacer.bottomAnchor.constraint(equalTo: bottomAnchor),
            spacer.leadingAnchor.constraint(equalTo: leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: trailingAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        if isSecureTextEntry {
            eyeImageView = UIImageView()
            eyeImageView.isUserInteractionEnabled = true
            eyeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEyeTap)))
            eyeImageView.translatesAutoresizingMaskIntoConstraints = false
            eyeImageView.image = UIImage(named: AppStrings.Assets.slashEye)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
            
            rightView = eyeImageView
            rightViewMode = .always
        }
        
        self.placeholder = placeholder
    }
    
    @objc func handleEyeTap() {
        eye.toggle()
        eyeImageView.image = UIImage(named: eye ? AppStrings.Assets.eye : AppStrings.Assets.slashEye)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
        isSecureTextEntry = !eye
    }
    
    @objc func textFieldChanged() {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let strongSelf = self else { return }
            if let text = strongSelf.text, !text.isEmpty {
                strongSelf.label.alpha = 1
            } else {
                strongSelf.label.alpha = 0
            }
            strongSelf.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange() {
        if let text = text, !text.isEmpty {
            label.alpha = 1
        } else {
            label.alpha = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: lineSpacing, right: secureTextEntry ? 35 : 0)
        return bounds.inset(by: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: lineSpacing, right: secureTextEntry ? 35 : 0)
        return bounds.inset(by: insets)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let imageSize: CGSize = CGSize(width: 25.0, height: 25.0)
        let rightViewWidth: CGFloat = imageSize.width
        let rightViewHeight: CGFloat = imageSize.height
        let rightViewY: CGFloat = (bounds.height - rightViewHeight) / 2.0 + 4.0
        let rightViewX: CGFloat = bounds.width - rightViewWidth - 8.0
            
        return CGRect(x: rightViewX, y: rightViewY, width: rightViewWidth, height: rightViewHeight)
    }
}
