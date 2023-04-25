//
//  AddReferenceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class AddAuthorReferenceViewController: UIViewController {
    weak var delegate: AddWebLinkReferenceDelegate?
    private var reference: Reference?
    private var firstTimeTap: Bool = true
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let referenceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let referenceDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private lazy var authorCitationTextView: UITextView = {
        let tf = UITextView()
        tf.tintColor = primaryColor
        tf.textColor = UIColor.lightGray
        tf.text = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658"
        tf.textContainerInset = UIEdgeInsets.zero
        tf.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        tf.textContainer.lineFragmentPadding = .zero
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.isScrollEnabled = true
        tf.backgroundColor = .quaternarySystemFill
        tf.layer.cornerRadius = 7
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var submitReferenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Add Author Citation", attributes: container)
        button.addTarget(self, action: #selector(handleContinueReference), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var deleteReferenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Remove Reference", attributes: container)
        button.addTarget(self, action: #selector(handleRemoveReference), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(reference: Reference? = nil) {
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        
        let stack = UIStackView(arrangedSubviews: [referenceTitleLabel, referenceDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        var textViewHeight = 120.0
        if let lineHeight = authorCitationTextView.font?.lineHeight {
            textViewHeight = lineHeight * 7
        }
        //referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //referenceWebLinkButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(stack, authorCitationTextView, separatorView, submitReferenceButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            
            authorCitationTextView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            authorCitationTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            authorCitationTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            authorCitationTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
            
            submitReferenceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitReferenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitReferenceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitReferenceButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        referenceTitleLabel.text = "Complete Citation"
        referenceDescriptionLabel.text = "Enhance your content with credible sources! Add proper citations with authors to give credit where it's due and strengthen the reliability of your post. Including reputable authors in your references showcases your commitment to accurate and trustworthy information, while upholding academic integrity and professionalism. Examples of sources with authors may include research papers, scholarly articles, official reports, expert opinions, and other reputable publications."
        authorCitationTextView.delegate = self
        
        if let reference = reference {
            authorCitationTextView.text = ""
            authorCitationTextView.tintColor = primaryColor
            authorCitationTextView.textColor = primaryColor
            firstTimeTap.toggle()
            authorCitationTextView.text = reference.referenceText
            
            scrollView.addSubview(deleteReferenceButton)
            NSLayoutConstraint.activate([
                deleteReferenceButton.bottomAnchor.constraint(equalTo: submitReferenceButton.topAnchor, constant: -5),
                deleteReferenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                deleteReferenceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                deleteReferenceButton.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }
    
    @objc func handleContinueReference() {
        guard let text = authorCitationTextView.text, !text.isEmpty else { return }
        let reference = Reference(option: .reference, referenceText: text)
        NotificationCenter.default.post(name: NSNotification.Name("PostReference"), object: nil, userInfo: ["reference": reference])
        dismiss(animated: true)
    }
    
    @objc func handleRemoveReference() {
        delegate?.didTapDeleteReference()
        dismiss(animated: true)
    }

    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension AddAuthorReferenceViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstTimeTap {
            textView.text = ""
            textView.tintColor = primaryColor
            textView.textColor = primaryColor
            firstTimeTap.toggle()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.isScrollEnabled = false
            textView.textColor = UIColor.lightGray
            textView.text = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658"
            firstTimeTap.toggle()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submitReferenceButton.isEnabled = textView.text.isEmpty ? false : true
    }
}
