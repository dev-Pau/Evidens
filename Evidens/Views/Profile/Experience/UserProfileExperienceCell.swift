//
//  Experience.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit

protocol UserProfileExperienceCellDelegate: AnyObject {
    func didTapEditExperience(_ cell: UICollectionViewCell, company: String, role: String, startDate: String, endDate: String)
}

class UserProfileExperienceCell: UICollectionViewCell {
    
    weak var delegate: UserProfileExperienceCellDelegate?
    
    private let professionCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //label.text = "Kinevic"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionJobTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //label.text = "Physiotherapist"
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
    
    private let jobIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        //label.text = "2016 - Present"
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditProfession), for: .touchUpInside)
        return button
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
        addSubviews(professionCenterTitleLabel, professionJobTitleLabel, calendarImage, jobIntervalLabel, separatorView, buttonImage)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionCenterTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            professionCenterTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            professionCenterTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionJobTitleLabel.topAnchor.constraint(equalTo: professionCenterTitleLabel.bottomAnchor, constant: 5),
            professionJobTitleLabel.leadingAnchor.constraint(equalTo: professionCenterTitleLabel.leadingAnchor),
            professionJobTitleLabel.trailingAnchor.constraint(equalTo: professionCenterTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: professionJobTitleLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: professionJobTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            jobIntervalLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            jobIntervalLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            jobIntervalLabel.trailingAnchor.constraint(equalTo: professionJobTitleLabel.trailingAnchor),
            jobIntervalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    func set(experienceInfo: [String: String]) {
        professionCenterTitleLabel.text = experienceInfo["company"]
        professionJobTitleLabel.text = experienceInfo["role"]
        jobIntervalLabel.text = experienceInfo["startDate"]! + " - " + experienceInfo["endDate"]!
    }
    
    @objc func handleEditProfession() {
        guard let company = professionCenterTitleLabel.text, let role = professionJobTitleLabel.text, let date = jobIntervalLabel.text else { return }
       
        let dateArray = date.split(separator: "-")

        delegate?.didTapEditExperience(self, company: company, role: role, startDate: String(dateArray[0]), endDate: String(dateArray[1]))
    }
    
}
