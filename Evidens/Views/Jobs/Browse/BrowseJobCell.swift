//
//  BrowseJobCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

protocol BrowseJobCellDelegate: AnyObject {
    func didBookmarkJob(_ cell: UICollectionViewCell, job: Job)
}

protocol BrowseSavedJobCellDelegate: AnyObject {
    func didUnsaveJob(_ cell: UICollectionViewCell, job: Job)
}

class BrowseJobCell: UICollectionViewCell {
    weak var delegate: BrowseJobCellDelegate?
    weak var savedDelegate: BrowseSavedJobCellDelegate?
    
    var viewModel: JobViewModel? {
        didSet {
            configureWithJob()
        }
    }
    
    var isUpdatingJoiningState: Bool? {
        didSet {
            bookmarkButton.setNeedsUpdateConfiguration()
        }
    }
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "company.profile")
        iv.backgroundColor = .quaternarySystemFill
        return iv
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
    
    private let jobPositionName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
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
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
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
    
    private let jobDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
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
    
    var separatorView: UIView = {
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
        isUpdatingJoiningState = false
        
        addSubviews(companyImageView, bookmarkButton, jobPositionName, companyNameLabel, jobLocationLabel, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 25),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 25),
            
            jobPositionName.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            jobPositionName.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            jobPositionName.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -10),
            
            companyNameLabel.topAnchor.constraint(equalTo: jobPositionName.bottomAnchor, constant: 2),
            companyNameLabel.leadingAnchor.constraint(equalTo: jobPositionName.leadingAnchor),
            companyNameLabel.trailingAnchor.constraint(equalTo: jobPositionName.trailingAnchor),
            
            jobLocationLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 2),
            jobLocationLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            jobLocationLabel.trailingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            /*
            jobDetailsLabel.topAnchor.constraint(equalTo: jobLocationLabel.bottomAnchor, constant: 5),
            jobDetailsLabel.leadingAnchor.constraint(equalTo: jobLocationLabel.leadingAnchor),
            jobDetailsLabel.trailingAnchor.constraint(equalTo: jobLocationLabel.trailingAnchor),
            */
            timestampLabel.topAnchor.constraint(equalTo: jobLocationLabel.bottomAnchor, constant: 2),
            timestampLabel.leadingAnchor.constraint(equalTo: jobLocationLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: jobLocationLabel.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: timestampLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        bookmarkButton.configurationUpdateHandler = { [unowned self] button in
            button.isUserInteractionEnabled = self.isUpdatingJoiningState! ? false : true
        }
        
        //companyImageView.layer.cornerRadius = 7
    }
    
    private func configureWithJob() {
        guard let viewModel = viewModel else { return }
        jobPositionName.text = viewModel.jobName
        jobLocationLabel.text = viewModel.jobLocation + " • " + viewModel.jobWorkplaceType
        //jobDetailsLabel.text = viewModel.jobProfession + " · " + viewModel.jobType
        timestampLabel.text = viewModel.jobTimestampString! + " ago" + viewModel.applicants
        bookmarkButton.configuration?.image = viewModel.bookMarkImage
    }
    
    func configureWithCompany(company: Company) {
        if let companyUrl = company.companyImageUrl, companyUrl != "" {
            companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
        }

        companyNameLabel.text = company.name
    }
    
    func configureWithBookmarkOptions() {
        bookmarkButton.isHidden = true
        addSubview(dotsImageButton)
        
        NSLayoutConstraint.activate([
            dotsImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
        ])
      
        dotsImageButton.menu = addMenuItems()
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Unsave", image: UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)) , handler: { _ in
                guard let viewModel = self.viewModel else { return }
                self.savedDelegate?.didUnsaveJob(self, job: viewModel.job)
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
    
    @objc func handleBookmark() {
        guard let viewModel = viewModel else { return }
        isUpdatingJoiningState = true
        HomeHeartAnimation.shared.animateLikeTap(bookmarkButton)
        delegate?.didBookmarkJob(self, job: viewModel.job)
    }
}
