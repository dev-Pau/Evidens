//
//  AddSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

protocol AddAboutViewControllerDelegate: AnyObject {
    func handleUpdateAbout()
}

class AddAboutViewController: UIViewController {
    
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
    
    weak var delegate: AddAboutViewControllerDelegate?
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.text = "Your about me section briefly summarize the most important information you want the community to know from you. It can be used to showcase your professional experience, skills, your professional brand or any other information you want to share."
        return label
    }()
    
    
    private lazy var aboutTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add about here"
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        //tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        tv.delegate = self
        tv.isScrollEnabled = true
        tv.tintColor = primaryColor
        tv.backgroundColor = .quaternarySystemFill
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSection()
        configureNavigationBar()
        configureUI()
    }
    
    private func fetchSection() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        DatabaseManager.shared.fetchAboutSection(forUid: uid) { result in
            switch result {
            case .success(let aboutText):
                self.aboutTextView.text = aboutText
                self.aboutTextView.handleTextDidChange()
                
            case .failure(_):
                print("Error fetching")
            }
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        //NotificationCenter.addObserver(<#T##self: NotificationCenter##NotificationCenter#>)
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(infoLabel, aboutTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            aboutTextView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            aboutTextView.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            aboutTextView.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
            aboutTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func handleDone() {
        print("Update About")
        guard let text = aboutTextView.text else { return }
        showLoadingView()
        DatabaseManager.shared.uploadAboutSection(with: text) { completed in
            self.dismissLoadingView()
            if completed {
                print("Text uploaded")
                self.delegate?.handleUpdateAbout()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
}

extension AddAboutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
