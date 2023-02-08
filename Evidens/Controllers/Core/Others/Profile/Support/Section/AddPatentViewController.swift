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
    func handleUpdatePatent()
}

class AddPatentViewController: UIViewController {
    
    private let user: User
    private var contributors: [User]?
    
    weak var delegate: AddPatentViewControllerDelegate?
    
    private var userIsEditing = false
    private var previousPatent: String = ""
    
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
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contributorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Contributors"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let contributorsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Worked in group? Add others that contributed to the patent"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var addContributorsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        button.configuration?.attributedTitle = AttributedString("Contributor", attributes: container)
        
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddContributors), for: .touchUpInside)
        return button
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(UserContributorCell.self, forCellWithReuseIdentifier: contributorsCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        patentTitleLabel.attributedText = generateSuperscriptFor(text: "Patent title")
        patentNumberLabel.attributedText = generateSuperscriptFor(text: "Patent number")
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(patentTitleLabel, patentTitleTextField, patentNumberLabel, patentNumberTextField, separatorView, addContributorsButton, contributorsLabel, contributorsDescriptionLabel, collectionView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            patentTitleTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
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
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            addContributorsButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            addContributorsButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            contributorsLabel.centerYAnchor.constraint(equalTo: addContributorsButton.centerYAnchor),
            contributorsLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            contributorsLabel.trailingAnchor.constraint(equalTo: addContributorsButton.trailingAnchor, constant: -10),
            
            contributorsDescriptionLabel.topAnchor.constraint(equalTo: addContributorsButton.bottomAnchor, constant: 5),
            contributorsDescriptionLabel.leadingAnchor.constraint(equalTo: contributorsLabel.leadingAnchor),
            contributorsDescriptionLabel.trailingAnchor.constraint(equalTo: contributorsLabel.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contributorsDescriptionLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
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
        var patentContributors = [String]()
        
        if let contributors = contributors {
            patentContributors = contributors.map({ $0.uid! })
        } else {
            patentContributors = [user.uid!]
        }
        
        progressIndicator.show(in: view)
        
        if userIsEditing {
            DatabaseManager.shared.updatePatent(previousPatent: previousPatent, patentTitle: title, patentNumber: number, contributors: patentContributors) { uploaded in

                self.progressIndicator.dismiss(animated: true)
                self.delegate?.handleUpdatePatent()
                if let count = self.navigationController?.viewControllers.count {
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 2 - 1])!, animated: true)
                }
            }
        } else {
            DatabaseManager.shared.uploadPatent(title: title, number: number, contributors: patentContributors) { uploaded in
                print("result is \(uploaded)")
                self.progressIndicator.dismiss(animated: true)
                self.delegate?.handleUpdatePatent()
                self.navigationController?.popViewController(animated: true)
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
    
    func configureWithPublication(patentTitle: String, patentNumber: String, patentDescription: String) {
        userIsEditing = true
        previousPatent = patentTitle
        
        patentTitleTextField.text = patentTitle
        patentNumberTextField.text = patentNumber
     
        textDidChange(patentTitleTextField)
        textDidChange(patentNumberTextField)
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
        return contributors?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contributorsCellReuseIdentifier, for: indexPath) as! UserContributorCell
        cell.xmarkButton.isHidden = true
        cell.set(user: contributors![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleAddContributors()
    }
}
