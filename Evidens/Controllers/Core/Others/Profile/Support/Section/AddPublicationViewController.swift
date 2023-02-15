//
//  AddPublicationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit
import JGProgressHUD

private let contributorsCellReuseIdentifier = "ContributorsCellReuseIdentifier"

protocol AddPublicationViewControllerDelegate: AnyObject {
    func handleUpdatePublication()
}

class AddPublicationViewController: UIViewController {
    
    weak var delegate: AddPublicationViewControllerDelegate?
    
    private let progressIndicator = JGProgressHUD()
    
    private let user: User
    private var contributors: [User]?
    
    private var userIsEditing = false
    private var previousPublication: String = ""
    
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
        let label = CustomLabel(placeholder: "Add publication")
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Adding publications is a great way to showcase your expertise in a particular field."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let publicationTitleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var publicationTitleTextField: UITextField = {
        let text = "Publication title *"
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
    
    private let urlPublicationLabel: UILabel = {
        let label = UILabel()
        //label.text = "Publication URL *"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var urlPublicationTextField: UITextField = {
        let text = "Publication URL *"
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
    
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        //label.text = "Date"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var publicationDateTextField: UITextField = {
        let text = "Date *"
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
    
    let publicationDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
        label.text = "Worked in group? Add others that contributed to the publication"
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
        configureDatePicker()
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
    
    private func configureDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddDate))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        publicationDateTextField.inputAccessoryView = toolbar
        publicationDateTextField.inputView = publicationDatePicker
        
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(UserContributorCell.self, forCellWithReuseIdentifier: contributorsCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        publicationTitleLabel.attributedText = generateSuperscriptFor(text: "Publication title")
        urlPublicationLabel.attributedText = generateSuperscriptFor(text: "Publication URL")
        publicationDateLabel.attributedText = generateSuperscriptFor(text: "Date")
        
        view.backgroundColor = .secondaryLabel
        view.addSubview(scrollView)
        
        scrollView.addSubviews(publicationTitleLabel, titleLabel, infoLabel, publicationTitleTextField, separatorView, addContributorsButton, contributorsLabel, contributorsDescriptionLabel, urlPublicationTextField, urlPublicationLabel, publicationDateLabel, publicationDateTextField, collectionView)
        
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
            
            
            publicationTitleTextField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            publicationTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            publicationTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            publicationTitleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            publicationTitleLabel.bottomAnchor.constraint(equalTo: publicationTitleTextField.topAnchor, constant: -2),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: publicationTitleTextField.leadingAnchor),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: publicationTitleTextField.trailingAnchor),
            
            urlPublicationTextField.topAnchor.constraint(equalTo: publicationTitleTextField.bottomAnchor, constant: 20),
            urlPublicationTextField.leadingAnchor.constraint(equalTo: publicationTitleTextField.leadingAnchor),
            urlPublicationTextField.trailingAnchor.constraint(equalTo: publicationTitleTextField.trailingAnchor),
            
            urlPublicationLabel.bottomAnchor.constraint(equalTo: urlPublicationTextField.topAnchor, constant: -2),
            urlPublicationLabel.leadingAnchor.constraint(equalTo: urlPublicationTextField.leadingAnchor),
            urlPublicationLabel.trailingAnchor.constraint(equalTo: urlPublicationTextField.trailingAnchor),
            
            publicationDateTextField.topAnchor.constraint(equalTo: urlPublicationTextField.bottomAnchor, constant: 20),
            publicationDateTextField.leadingAnchor.constraint(equalTo: urlPublicationTextField.leadingAnchor),
            publicationDateTextField.trailingAnchor.constraint(equalTo: urlPublicationTextField.trailingAnchor),
            
            publicationDateLabel.bottomAnchor.constraint(equalTo: publicationDateTextField.topAnchor, constant: -2),
            publicationDateLabel.leadingAnchor.constraint(equalTo: publicationDateTextField.leadingAnchor),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationDateTextField.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: publicationDateTextField.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: publicationDateTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: publicationDateTextField.trailingAnchor),
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
    
    func updatePublicationForm() {
        guard let title = publicationTitleTextField.text, let dateText = publicationDateTextField.text, let url = urlPublicationTextField.text  else { return }
        navigationItem.rightBarButtonItem?.isEnabled = !title.isEmpty && !dateText.isEmpty && !url.isEmpty  ? true : false
    }
    
    @objc func handleDone() {
        guard let title = publicationTitleTextField.text, let url = urlPublicationTextField.text, let date = publicationDateTextField.text else { return }
        
        var patentContributors = [String]()
        
        if let contributors = contributors {
            patentContributors = contributors.map({ $0.uid! })
        } else {
            patentContributors = [user.uid!]
        }
        
        progressIndicator.show(in: view)
    
        if userIsEditing {
            DatabaseManager.shared.updatePublication(previousPublication: previousPublication, publicationTitle: title, publicationUrl: url, publicationDate: date, contributors: patentContributors) { uploaded in
                self.progressIndicator.dismiss(animated: true)
                self.delegate?.handleUpdatePublication()
                if let count = self.navigationController?.viewControllers.count {
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 2 - 1])!, animated: true)
                }
            }
        } else {
            DatabaseManager.shared.uploadPublication(title: title, url: url, date: date, contributors: patentContributors) { uploaded in
                self.progressIndicator.dismiss(animated: true)
                self.delegate?.handleUpdatePublication()
                self.navigationController?.popViewController(animated: true)
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
    
    @objc func handleAddDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        publicationDateTextField.text = formatter.string(from: publicationDatePicker.date)
        textDidChange(publicationDateTextField)
        view.endEditing(true)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == publicationTitleTextField {
            if count != 0 {
                publicationTitleLabel.isHidden = false
            } else {
                publicationTitleLabel.isHidden = true
            }
            
            updatePublicationForm()
        }
        
        if textField == publicationDateTextField {
            if count != 0 {
                publicationDateLabel.isHidden = false
            } else {
                publicationDateLabel.isHidden = true
            }
        }
        
        if textField == urlPublicationTextField {
            if count != 0 {
                urlPublicationLabel.isHidden = false
            } else {
                urlPublicationLabel.isHidden = true
            }
        }
        
        updatePublicationForm()
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
    
    func configureWithPublication(publicationTitle: String, publicationUrl: String, publicationDate: String) {
        userIsEditing = true
        previousPublication = publicationTitle
        
        publicationTitleTextField.text = publicationTitle
        urlPublicationTextField.text = publicationUrl
        publicationDateTextField.text = publicationDate

        textDidChange(publicationTitleTextField)
        textDidChange(urlPublicationTextField)
        textDidChange(publicationDateTextField)
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}


extension AddPublicationViewController: AddContributorsViewControllerDelegate {
    func didAddContributors(contributors: [User]) {
        self.contributors = contributors
        collectionView.reloadData()
    }
}

extension AddPublicationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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

