//
//  AddPatentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit
import JGProgressHUD

private let contributorsCellReuseIdentifier = "ContributorsCellReuseIdentifier"

protocol AddPatentViewControllerDelegate: AnyObject {
    func handleUpdatePatent(patent: Patent)
    func handleDeletePatent(patent: Patent)
}

class AddPatentViewController: UIViewController {
    
    private let user: User
    
    private var contributorUids = [String]()
    private var contributors = [User]()
    
    weak var delegate: AddPatentViewControllerDelegate?
    
    private var userIsEditing = false
    private let previousPatent: Patent?
    private var patent = Patent(title: "", number: "", contributorUids: [])
    
    private let progressIndicator = JGProgressHUD()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = CustomLabel(placeholder: "Add patent")
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Adding patents is a great way to showcase your expertise in a particular field."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patentTitleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var patentTitleTextField: UITextField = {
        let text = "Patent title *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private let patentNumberLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var patentNumberTextField: UITextField = {
        let text = "Patent number *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contributorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Contributors"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let contributorsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Worked in group? Add others from your network that contributed to the patent"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var addContributorsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .small
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddContributors), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 19, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Delete", attributes: container)
    
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .white
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDeletePatent), for: .touchUpInside)
        return button
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureWithPatent(patent: previousPatent)
    }
    
    init(user: User, previousPatent: Patent? = nil) {
        self.user = user
        self.previousPatent = previousPatent
        if let previousPatent = previousPatent {
            self.contributorUids = previousPatent.contributorUids
            self.userIsEditing = true
        } else {
            contributors = [user]
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: userIsEditing ? "Edit" : "Add", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(120)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func configureUI() {
        title = "Patent"
        titleLabel.text = userIsEditing ? "Edit Patent" : "Add Patent"
        deleteButton.isHidden = userIsEditing ? false : true
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(UserContributorCell.self, forCellWithReuseIdentifier: contributorsCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        patentTitleLabel.attributedText = generateSuperscriptFor(text: "Patent title")
        patentNumberLabel.attributedText = generateSuperscriptFor(text: "Patent number")
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(patentTitleLabel, titleLabel, infoLabel, patentTitleTextField, patentNumberLabel, patentNumberTextField, separatorView, addContributorsButton, contributorsLabel, contributorsDescriptionLabel, collectionView, deleteButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            
            patentTitleTextField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 40),
            patentTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            patentTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            patentTitleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            patentTitleLabel.bottomAnchor.constraint(equalTo: patentTitleTextField.topAnchor, constant: -2),
            patentTitleLabel.leadingAnchor.constraint(equalTo: patentTitleTextField.leadingAnchor),
            patentTitleLabel.trailingAnchor.constraint(equalTo: patentTitleTextField.trailingAnchor),
            
            patentNumberTextField.topAnchor.constraint(equalTo: patentTitleTextField.bottomAnchor, constant: 20),
            patentNumberTextField.leadingAnchor.constraint(equalTo: patentTitleTextField.leadingAnchor),
            patentNumberTextField.trailingAnchor.constraint(equalTo: patentTitleTextField.trailingAnchor),
            patentNumberTextField.heightAnchor.constraint(equalToConstant: 35),
            
            patentNumberLabel.bottomAnchor.constraint(equalTo: patentNumberTextField.topAnchor, constant: -2),
            patentNumberLabel.leadingAnchor.constraint(equalTo: patentNumberTextField.leadingAnchor),
            patentNumberLabel.trailingAnchor.constraint(equalTo: patentNumberTextField.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: patentNumberTextField.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: patentNumberTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: patentNumberTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            addContributorsButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            addContributorsButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            contributorsLabel.centerYAnchor.constraint(equalTo: addContributorsButton.centerYAnchor),
            contributorsLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            contributorsLabel.trailingAnchor.constraint(equalTo: addContributorsButton.trailingAnchor, constant: -10),
            
            contributorsDescriptionLabel.topAnchor.constraint(equalTo: addContributorsButton.bottomAnchor, constant: 5),
            contributorsDescriptionLabel.leadingAnchor.constraint(equalTo: contributorsLabel.leadingAnchor),
            contributorsDescriptionLabel.trailingAnchor.constraint(equalTo: contributorsLabel.trailingAnchor),
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            collectionView.topAnchor.constraint(equalTo: contributorsDescriptionLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor)
        ])
    }
    
    private func updatePatentForm() {
        guard let text = patentTitleTextField.text, let number = patentNumberTextField.text else { return }
        if !text.isEmpty && !number.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func handleDone() {
        guard let title = patentTitleTextField.text, let number = patentNumberTextField.text else { return }

        // Create the new patent to upload or update
        patent.title = title
        patent.number = number
        patent.contributorUids = contributors.map({ $0.uid! })
        
        progressIndicator.show(in: view)
        
        if userIsEditing {
            guard let previousPatent = previousPatent else { return }
            DatabaseManager.shared.updatePatent(from: previousPatent, to: patent) { uploaded in
                if uploaded {
                    self.progressIndicator.dismiss(animated: true)
                    self.delegate?.handleUpdatePatent(patent: self.patent)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            DatabaseManager.shared.uploadPatent(patent: patent) { uploaded in
                if uploaded {
                    self.progressIndicator.dismiss(animated: true)
                    self.delegate?.handleUpdatePatent(patent: self.patent)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == patentTitleTextField {
            if count != 0 {
                patentTitleLabel.isHidden = false
            } else {
                patentTitleLabel.isHidden = true
            }
            
        } else if textField == patentNumberTextField {
            if count != 0 {
                patentNumberLabel.isHidden = false
            } else {
                patentNumberLabel.isHidden = true
            }
        }
        
        updatePatentForm()
    }
    
    @objc func handleDeletePatent() {
        guard let previousPatent = previousPatent else { return }
        displayMEDestructiveAlert(withTitle: "Delete Patent", withMessage: "Are you sure you want to delete this patent?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.deletePatent(patent: previousPatent) { deleted in
                self.progressIndicator.dismiss(animated: true)
                if deleted {
                    self.delegate?.handleDeletePatent(patent: previousPatent)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func handleAddContributors() {
        let controller = AddContributorsViewController(user: user, selectedUsers: contributors)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
    
    func configureWithPatent(patent: Patent?) {
        guard let patent = patent else { return }
        patentTitleTextField.text = patent.title
        patentNumberTextField.text = patent.number
        textDidChange(patentTitleTextField)
        textDidChange(patentNumberTextField)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        UserService.fetchUsers(withUids: patent.contributorUids) { users in
            self.contributors = users
            self.collectionView.reloadData()
        }
    }
}


extension AddPatentViewController: AddContributorsViewControllerDelegate {
    func didAddContributors(contributors: [User]) {
        self.contributors = contributors
        collectionView.reloadData()
    }
}

extension AddPatentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contributors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contributorsCellReuseIdentifier, for: indexPath) as! UserContributorCell
        cell.xmarkButton.isHidden = true
        cell.set(user: contributors[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleAddContributors()
    }
}
