//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/1/23.
//

import UIKit

import UIKit

private let groupBrowseSkeletonCellReuseIdentifier = "GroupBrowseSkeletonReuseIdentifier"
private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupFooterReuseIdentifier = "GroupFooterReuseIdentifier"
private let emptyGroupCellReuseIdentifier = "EmptyGroupCellReuseIdentifier"

class RequestSelectorCell: UICollectionViewCell {
    
    weak var delegate: GroupSelectorCellDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var loaded: Bool = false
    private var groups = [Group]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        fetchUserGroups()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchUserGroups() {
        DatabaseManager.shared.fetchUserIdPendingGroups { memberTypeGroup in
            switch memberTypeGroup {
            case .success(let memberTypeGroup):
                let groupIds = memberTypeGroup.map({ $0.groupId })
                GroupService.fetchUserGroups(withGroupIds: groupIds) { groups in
                    self.groups = groups
                    self.loaded = true
                    self.collectionView.isScrollEnabled = true
                    self.collectionView.reloadData()
                }
            case .failure(_):
                self.loaded = true
                self.collectionView.isScrollEnabled = true
                self.collectionView.reloadData()
            }
            
        }
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        collectionView.frame = bounds
        collectionView.register(GroupBrowseSkeletonCell.self, forCellWithReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier)
        collectionView.register(GroupPendingCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        collectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension RequestSelectorCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if loaded {
            return groups.count > 0 ? groups.count : 1
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier, for: indexPath) as! GroupBrowseSkeletonCell
            return cell
        }
        
        if groups.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.delegate = self
            cell.set(withTitle: "We could not find any active group requests.", withDescription: "Discover listed groups or communities that share your interests, vision or goals.", withButtonText: "Discover")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupPendingCell
            cell.viewModel = GroupViewModel(group: groups[indexPath.row])
            cell.setGroupRole(role: .pending)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !loaded || groups.isEmpty { return }
        let group = groups[indexPath.row]
        
        delegate?.didSelectGroup(group, memberType: .pending)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if loaded {
            if groups.isEmpty {
                return CGSize.zero
            } else {
                return CGSize(width: UIScreen.main.bounds.width - 30, height: 50)
            }
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter && loaded {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier, for: indexPath) as! GroupBrowseFooter
            footer.delegate = self
            return footer
        } else {
            return UICollectionReusableView()
        }
    }
}

extension RequestSelectorCell: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        delegate?.didTapDiscover()
    }
}

extension RequestSelectorCell: GroupBrowseFooterDelegate {
    func didTapDiscoverGroups() {
        delegate?.didTapDiscover()
    }
}

