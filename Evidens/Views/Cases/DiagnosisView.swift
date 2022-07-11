//
//  DiagnosisView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/7/22.
//

import UIKit

protocol DiagnosisViewDelegate: AnyObject {
    func didTapShowMore(expanded: Bool)
}

class DiagnosisView: UIView {
    
    private var isExpanded: Bool = false
    
    weak var delegate: DiagnosisViewDelegate?
    
    private let diagnosisTitle: UILabel = {
        let label = UILabel()
        label.text = "Diagnosis added"
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "pencil")?.scalePreservingAspectRatio(targetSize: CGSize(width: 16, height: 16)).withTintColor(blackColor)
        button.configuration?.baseBackgroundColor = lightGrayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    var diagnosisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = blackColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(diagnosisLabel, diagnosisTitle, editButton)
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderColor = lightGrayColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 7
        
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            diagnosisTitle.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            diagnosisTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            diagnosisTitle.heightAnchor.constraint(equalToConstant: 20),
            
            diagnosisLabel.topAnchor.constraint(equalTo: diagnosisTitle.bottomAnchor, constant: 15),
            diagnosisLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            diagnosisLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
    
    @objc func handleEdit() {
        
    }
}
