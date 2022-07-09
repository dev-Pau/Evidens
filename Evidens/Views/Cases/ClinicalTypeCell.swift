//
//  ClinicalTypeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

class ClinicalTypeCell: UITableViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectedOptionButton.configuration?.image = isSelected ? UIImage(systemName: "smallcircle.fill.circle.fill") : UIImage(systemName: "circle")
            if isSelected {
                print("is selected")
            }
        }
    }
    
    private let typeTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let selectedOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.baseForegroundColor = primaryColor

        button.configuration?.cornerStyle = .capsule

        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        selectionStyle = .none
        backgroundColor = .white
        
        addSubviews(typeTitle, selectedOptionButton)
        
        NSLayoutConstraint.activate([
            selectedOptionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            selectedOptionButton.heightAnchor.constraint(equalToConstant: 15),
            selectedOptionButton.widthAnchor.constraint(equalToConstant: 15),
            
            typeTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            typeTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            typeTitle.trailingAnchor.constraint(equalTo: selectedOptionButton.leadingAnchor, constant: 10),
            typeTitle.heightAnchor.constraint(equalToConstant: 20)

        ])
    }
    
    func set(title: String) {
        typeTitle.text = title
    }
}
