//
//  Education.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit

protocol UserProfileEducationCellDelegate: AnyObject {
    func didTapEditEducation(_ cell: UICollectionViewCell, educationSchool: String, educationDegree: String, educationField: String, educationStartDate: String, educationEndDate: String)
}

class UserProfileEducationCell: UICollectionViewCell {
    
    weak var delegate: UserProfileEducationCellDelegate?
    
    private let educationCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //label.text = "Universitat de Barcelona"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //label.text = "Physiotherapy"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendarImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let educationIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        //label.text = "2016 - Present"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditEducation), for: .touchUpInside)
        return button
    }()
    
    private let educationTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "rosette")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let educationTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        //label.text = "Master's degree"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubviews(educationCenterTitleLabel, educationTitleLabel, calendarImage, educationIntervalLabel, educationTypeImage, educationTypeLabel, separatorView, buttonImage)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            educationCenterTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            educationCenterTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            educationCenterTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            educationTitleLabel.topAnchor.constraint(equalTo: educationCenterTitleLabel.bottomAnchor, constant: 10),
            educationTitleLabel.leadingAnchor.constraint(equalTo: educationCenterTitleLabel.leadingAnchor),
            educationTitleLabel.trailingAnchor.constraint(equalTo: educationCenterTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: educationTitleLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: educationTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            educationIntervalLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            educationIntervalLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            educationIntervalLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            
            educationTypeImage.topAnchor.constraint(equalTo: educationIntervalLabel.bottomAnchor, constant: 10),
            educationTypeImage.leadingAnchor.constraint(equalTo: educationTitleLabel.leadingAnchor),
            educationTypeImage.widthAnchor.constraint(equalToConstant: 15),
            educationTypeImage.heightAnchor.constraint(equalToConstant: 15),
            
            educationTypeLabel.centerYAnchor.constraint(equalTo: educationTypeImage.centerYAnchor),
            educationTypeLabel.leadingAnchor.constraint(equalTo: educationTypeImage.trailingAnchor, constant: 10),
            educationTypeLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            educationTypeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    func set(educationInfo: [String: String]) {
        educationCenterTitleLabel.text = educationInfo["school"]
        educationTitleLabel.text = educationInfo["degree"]
        educationIntervalLabel.text = educationInfo["startDate"]! + " - " + educationInfo["endDate"]!
        educationTypeLabel.text = educationInfo["field"]
    }
    
    @objc func handleEditEducation() {
        guard let school = educationCenterTitleLabel.text, let degree = educationTitleLabel.text, let field = educationTypeLabel.text, let date = educationIntervalLabel.text else { return }
        
        let dateArray = date.split(separator: "-")

        delegate?.didTapEditEducation(self, educationSchool: school, educationDegree: degree, educationField: field, educationStartDate: String(dateArray[0]), educationEndDate: String(dateArray[1]))
    }
}
