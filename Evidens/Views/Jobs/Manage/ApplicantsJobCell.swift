//
//  ApplicantsJobCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/2/23.
//

import UIKit

protocol ApplicantsJobCellDelegate: AnyObject {
    func didTapRemoveApplicant(job: Job)
}

class ApplicantsJobCell: UICollectionViewCell {
    weak var delegate: ApplicantsJobCellDelegate?
    
    var viewModel: JobViewModel? {
        didSet {
            configureWithJob()
        }
    }
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let jobLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let jobPositionName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .label
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
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
        addSubviews(companyImageView, companyNameLabel, jobLocationLabel, jobPositionName, dotsImageButton, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            
            dotsImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            jobPositionName.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            jobPositionName.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            jobPositionName.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            companyNameLabel.topAnchor.constraint(equalTo: jobPositionName.bottomAnchor, constant: 2),
            companyNameLabel.leadingAnchor.constraint(equalTo: jobPositionName.leadingAnchor),
            companyNameLabel.trailingAnchor.constraint(equalTo: jobPositionName.trailingAnchor),
            
            jobLocationLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 2),
            jobLocationLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            jobLocationLabel.trailingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: jobLocationLabel.bottomAnchor, constant: 2),
            timestampLabel.leadingAnchor.constraint(equalTo: jobLocationLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: jobLocationLabel.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: timestampLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        dotsImageButton.menu = addMenuItems()
    }
    
    private func configureWithJob() {
        guard let viewModel = viewModel else { return }
        jobPositionName.text = viewModel.jobName
        jobLocationLabel.text = viewModel.jobLocation + " • " + viewModel.jobWorkplaceType
        timestampLabel.text = viewModel.jobTimestampString! + " ago" + viewModel.applicants
    }
    
    func configureWithCompany(company: Company) {
        companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
        companyNameLabel.text = company.name
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Remove", image: UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), attributes: .destructive, handler: { _ in
                guard let viewModel = self.viewModel else { return }
                self.delegate?.didTapRemoveApplicant(job: viewModel.job)
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
}
