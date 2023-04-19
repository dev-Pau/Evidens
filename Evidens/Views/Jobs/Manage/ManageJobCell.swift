//
//  ManageJobCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

protocol ManageJobCellDelegate: AnyObject {
    func didTapManageOption(_ cell: UICollectionViewCell, _ option: Job.ManageJobOptions)
}

class ManageJobCell: UICollectionViewCell {
    weak var delegate: ManageJobCellDelegate?

    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .label
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let jobTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let locationWorksplaceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let jobStageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(companyImageView, dotsImageButton, jobTitle, locationWorksplaceLabel, jobStageButton, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: companyImageView.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            jobTitle.topAnchor.constraint(equalTo: companyImageView.topAnchor, constant: 2),
            jobTitle.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            jobTitle.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            locationWorksplaceLabel.topAnchor.constraint(equalTo: jobTitle.bottomAnchor),
            locationWorksplaceLabel.leadingAnchor.constraint(equalTo: jobTitle.leadingAnchor),
            locationWorksplaceLabel.trailingAnchor.constraint(equalTo: jobTitle.trailingAnchor),
            
            jobStageButton.topAnchor.constraint(equalTo: locationWorksplaceLabel.bottomAnchor, constant: 5),
            jobStageButton.leadingAnchor.constraint(equalTo: jobTitle.leadingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: jobStageButton.bottomAnchor, constant: 5),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            timestampLabel.leadingAnchor.constraint(equalTo: locationWorksplaceLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: jobTitle.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        //companyImageView.layer.cornerRadius = 7
        dotsImageButton.menu = addMenuItems()
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: Job.ManageJobOptions.edit.rawValue, image: UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { _ in
                self.delegate?.didTapManageOption(self, .edit)
            }),
            UIAction(title: Job.ManageJobOptions.applicants.rawValue, image: UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), handler: { _ in
                self.delegate?.didTapManageOption(self, .applicants)
            }),
            UIAction(title: Job.ManageJobOptions.delete.rawValue, image: UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), attributes: .destructive, handler: { _ in
                self.delegate?.didTapManageOption(self, .delete)
            })
        ])
        
        dotsImageButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func configure(withJob viewModel: JobViewModel, withCompany company: Company) {
        if let imageUrl = company.companyImageUrl, imageUrl != "" {
            companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
        }

        jobTitle.text = viewModel.jobName
        locationWorksplaceLabel.text = viewModel.jobLocation + " • " + viewModel.jobWorkplaceType
        timestampLabel.text = "Created " + viewModel.jobTimestampString! + " ago" + viewModel.applicants
        jobStageButton.configuration?.baseBackgroundColor = viewModel.jobStageBackgroundColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .medium)
        jobStageButton.configuration?.attributedTitle = AttributedString(viewModel.jobStageText, attributes: container)
    }
}
