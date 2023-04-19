//
//  GroupSelectorCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/1/23.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupFooterReuseIdentifier = "GroupFooterReuseIdentifier"
private let emptyGroupCellReuseIdentifier = "EmptyGroupCellReuseIdentifier"

protocol GroupSelectorCellDelegate: AnyObject {
    func didSelectGroup(_ group: Group, memberType: Group.MemberType)
    func didTapDiscover()
}

class GroupSelectorCell: UICollectionViewCell {
    
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
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private var memberType = [MemberTypeGroup]()
    
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
        DatabaseManager.shared.fetchUserIdMemberTypeGroups { memberTypeGroup in
            switch memberTypeGroup {
            case .success(let memberTypeGroup):
                self.memberType = memberTypeGroup
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
        collectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        collectionView.register(GroupBrowseFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: groupFooterReuseIdentifier)
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyGroupCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension GroupSelectorCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
        if groups.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyGroupCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "groups.empty")!, withTitle: "We could not find any group you are a part of - yet.", withDescription: "Discover listed groups or communities that share your interests, vision or goals.", withButtonText: "Discover")
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupBrowseCell
            cell.viewModel = GroupViewModel(group: groups[indexPath.row])
            
            let memberIndex = memberType.firstIndex { memberType in
                if groups[indexPath.row].groupId == memberType.groupId {
                    return true
                }
                return false
            }
            
            if let memberIndex = memberIndex { cell.setGroupRole(role: memberType[memberIndex].memberType) }
          
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !loaded || groups.isEmpty { return }
        let group = groups[indexPath.row]
        
        let memberIndex = memberType.firstIndex { memberType in
            if group.groupId == memberType.groupId {
                return true
            }
            return false
        }
        
        if let memberIndex = memberIndex { delegate?.didSelectGroup(group, memberType: memberType[memberIndex].memberType) }
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

extension GroupSelectorCell: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        delegate?.didTapDiscover()
    }
}

extension GroupSelectorCell: GroupBrowseFooterDelegate {
    func didTapDiscoverGroups() {
        delegate?.didTapDiscover()
    }
}
