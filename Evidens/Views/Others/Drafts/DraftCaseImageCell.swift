//
//  DraftCaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/24.
//

import UIKit

private let imageCellReuseIdentifier = "ImageCellReuseIdentifier"

class DraftCaseImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet {
            configure()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title1, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title1, weight: .regular)
        label.numberOfLines = 3
        return label
    }()
    
    private var collectionView: UICollectionView!
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let phaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .leading
        configuration.contentInsets = .zero
        configuration.imagePadding = 5
        configuration.baseForegroundColor = .secondaryLabel
        configuration.image = UIImage(systemName: AppStrings.Icons.circleInfoFill)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15))
        button.configuration = configuration
        
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.addFont(size: 14.0, scaleStyle: .title1, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: imageCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubviews(collectionView, titleLabel, dateLabel, phaseButton, contentLabel, separator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
            
            dateLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentLabel.trailingAnchor),
            
            phaseButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            phaseButton.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            phaseButton.trailingAnchor.constraint(lessThanOrEqualTo: contentLabel.trailingAnchor),

            separator.topAnchor.constraint(equalTo: phaseButton.bottomAnchor, constant: 10),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        contentLabel.text = viewModel.content
        dateLabel.text = viewModel.detailedCase
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .regular)
        
        phaseButton.configuration?.attributedTitle = AttributedString(viewModel.visible, attributes: container)
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(120))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension DraftCaseImageCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfImages ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath) as! CaseImageCell
        
        if let viewModel {
            cell.caseImageView.sd_setImage(with: URL(string: viewModel.images[indexPath.row]))
        }

        return cell
    }
}
