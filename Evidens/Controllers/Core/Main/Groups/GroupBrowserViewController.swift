//
//  GroupBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/12/22.
//

import UIKit

private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"
private let groupBrowseSkeletonCellReuseIdentifier = "GroupBrowseSkeletonCellReuseIdentifier"

protocol GroupBrowserViewControllerDelegate: AnyObject {
    func didTapGroupCreate()
    func didTapDiscoverGroup()
}

class GroupBrowserViewController: UIViewController {
    
    weak var delegate: GroupBrowserViewControllerDelegate?
    
    private var loaded: Bool = false
    
    private var groups = [Group]()

    private let groupCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var discoverGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.baseBackgroundColor = lightColor
        
        button.configuration?.image = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23)).withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        
        button.addTarget(self, action: #selector(handleDiscoverTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var discoverLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Discover existing groups"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.textColor = .black
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDiscoverTap)))
        return label
    }()
    
    private lazy var createGroupLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new group"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCreateTap)))
        return label
    }()
    
    private lazy var createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.cornerStyle = .capsule
        
        button.configuration?.baseBackgroundColor = primaryColor
        button.addTarget(self, action: #selector(handleCreateTap), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchUserGroups()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded { groupCollectionView.reloadData() }
    }
    
    private func configureNavigationBar() {
        title = "Groups"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), style: .done, target: self, action: #selector(handleHideGroupBrowser))
    }
    
    private func configureCollectionView() {
        groupCollectionView.register(GroupBrowseSkeletonCell.self, forCellWithReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier)
        groupCollectionView.register(GroupBrowseCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
    }
    
    private func configureUI() {
        view.addSubviews(groupCollectionView, discoverGroupButton, createGroupButton, separatorView, discoverLabel, createGroupLabel)
        NSLayoutConstraint.activate([
            createGroupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            createGroupButton.widthAnchor.constraint(equalToConstant: 35),
            createGroupButton.heightAnchor.constraint(equalToConstant: 35),
            
            discoverGroupButton.bottomAnchor.constraint(equalTo: createGroupButton.topAnchor, constant: -10),
            discoverGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            discoverGroupButton.widthAnchor.constraint(equalToConstant: 35),
            discoverGroupButton.heightAnchor.constraint(equalToConstant: 35),
            
            separatorView.bottomAnchor.constraint(equalTo: discoverGroupButton.topAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            groupCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            groupCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            groupCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            groupCollectionView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            createGroupLabel.centerYAnchor.constraint(equalTo: createGroupButton.centerYAnchor),
            createGroupLabel.leadingAnchor.constraint(equalTo: createGroupButton.trailingAnchor, constant: 10),
            createGroupLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            discoverLabel.centerYAnchor.constraint(equalTo: discoverGroupButton.centerYAnchor),
            discoverLabel.leadingAnchor.constraint(equalTo: discoverGroupButton.trailingAnchor, constant: 10),
            discoverLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func fetchUserGroups() {
        GroupService.fetchUserGroups { groups in
            self.groups = groups
            self.loaded = true
            self.groupCollectionView.isScrollEnabled = true
            self.groupCollectionView.reloadData()
        }
    }
    
    @objc func handleHideGroupBrowser() {
        dismiss(animated: true)
    }
    
    @objc func handleCreateTap() {
        dismiss(animated: true)
        delegate?.didTapGroupCreate()
    }
    
    @objc func handleDiscoverTap() {
        dismiss(animated: true)
        delegate?.didTapDiscoverGroup()

    }
}

extension GroupBrowserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? groups.count : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupBrowseSkeletonCellReuseIdentifier, for: indexPath) as! GroupBrowseSkeletonCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupBrowseCell
        cell.viewModel = GroupViewModel(group: groups[indexPath.row])
        return cell
    }
}
