//
//  ProfessionSelectedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/3/23.
//

import UIKit

protocol ProfessionSelectedCellDelegate: AnyObject {
    func didRestoreMenu()
    func didSelectSearchTopic(_ topic: String)
    func didSelectSearchCategory(_ category: Search.Topics)
}

class ProfessionSelectedCell: UICollectionViewCell {
    weak var delegate: ProfessionSelectedCellDelegate?
    //weak var delegate: FilterCasesCellDelegate?
    private let searchDataSource = Search.Topics.allCases
    
    /*
    var selectedTag: String? {
        didSet {
            configureMenuWithTag()
        }
    }
    
    var selectedCategory: String? {
        didSet {
            configureMenuWithTag()
        }
    }
*/
    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.textColor = .systemBackground
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
        layer.cornerRadius = 15
        backgroundColor = .label
        addSubviews(tagsLabel)
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    private func configureMenuWithTag() {
        //guard let tag = selectedTag else { return }
        //delegate?.showDisciplinesMenu()
        /*
        
        let topics = UIMenu(title: "Topics", subtitle: tag, image: UIImage(systemName: "arrow.up.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), options: .singleSelection, children: [
            UIAction(title: Profession.getAllProfessions()[0].profession, state: Profession.getAllProfessions()[0].profession == tag ? .on : .off,  handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[0].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[1].profession, state: Profession.getAllProfessions()[1].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[1].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[2].profession, state: Profession.getAllProfessions()[2].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[2].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[3].profession, state: Profession.getAllProfessions()[3].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[3].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[4].profession, state: Profession.getAllProfessions()[4].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[4].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[5].profession, state: Profession.getAllProfessions()[5].profession == tag ? .on : .off,handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[5].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[6].profession, state: Profession.getAllProfessions()[6].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[6].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[7].profession, state: Profession.getAllProfessions()[7].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[7].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[8].profession, state: Profession.getAllProfessions()[8].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[8].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[9].profession, state: Profession.getAllProfessions()[9].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[9].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[10].profession, state: Profession.getAllProfessions()[10].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[10].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[11].profession, state: Profession.getAllProfessions()[11].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[11].profession)
            }),
            UIAction(title: Profession.getAllProfessions()[12].profession, state: Profession.getAllProfessions()[0].profession == tag ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchTopic(Profession.getAllProfessions()[12].profession)
            }),
        ])

        let category = UIMenu(title: "Categories", subtitle: selectedCategory ?? nil, image: UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), options: .singleSelection, children: [
            UIAction(title: searchDataSource[0].rawValue, state: selectedCategory ?? "" == searchDataSource[0].rawValue ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchCategory(self.searchDataSource[0])
            }),
            UIAction(title: searchDataSource[1].rawValue, state: selectedCategory ?? "" == searchDataSource[1].rawValue ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchCategory(self.searchDataSource[1])
            }),
            UIAction(title: searchDataSource[2].rawValue, state: selectedCategory ?? "" == searchDataSource[2].rawValue ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchCategory(self.searchDataSource[2])
            }),
            UIAction(title: searchDataSource[3].rawValue, state: selectedCategory ?? "" == searchDataSource[3].rawValue ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchCategory(self.searchDataSource[3])
            }),
            UIAction(title: searchDataSource[4].rawValue, state: selectedCategory ?? "" == searchDataSource[4].rawValue ? .on : .off, handler: { _ in
                self.delegate?.didSelectSearchCategory(self.searchDataSource[4])
            })
        ])
        
        let reset = UIAction(title: "Reset Filters", image: UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))) { _ in
            self.delegate?.didRestoreMenu()
        }
                
        button.menu = UIMenu(title: "", children: [topics, category, reset])
        button.showsMenuAsPrimaryAction = true
         */
    }
    
    func setText(text: String) {
        tagsLabel.text = "     \(text)     "
    }
    
    /*
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 layer.borderColor = UIColor.quaternarySystemFill.cgColor
             }
         }
    }
     */
    
    @objc func handleImageTap() {
        //delegate?.didTapFilterImage(self)
    }
}


