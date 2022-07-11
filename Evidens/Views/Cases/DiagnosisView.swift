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
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubviews(diagnosisLabel, diagnosisTitle, editLabel)
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderColor = lightGrayColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 7
        
        NSLayoutConstraint.activate([
            editLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            editLabel.heightAnchor.constraint(equalToConstant: 20),
            editLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            diagnosisTitle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            diagnosisTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            diagnosisTitle.heightAnchor.constraint(equalToConstant: 20),
            
            diagnosisLabel.topAnchor.constraint(equalTo: diagnosisTitle.bottomAnchor, constant: 10),
            diagnosisLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            diagnosisLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
}
