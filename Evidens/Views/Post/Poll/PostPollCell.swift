//
//  PostPollCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/22.
//

import UIKit

class PostPollCell: UITableViewCell {
    
    var titlePollOption: UITextField = {
        let tf = METextField(placeholder: "", withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.backgroundColor = .white
        tf.layer.borderColor = primaryColor.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        //tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        addSubview(titlePollOption)
        
        NSLayoutConstraint.activate([
            titlePollOption.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titlePollOption.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titlePollOption.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titlePollOption.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
