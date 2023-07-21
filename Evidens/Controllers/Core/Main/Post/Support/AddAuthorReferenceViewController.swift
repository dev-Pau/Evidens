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
    private var referenceButton: UIButton!
    private var cancelButton: UIButton!
    private var firstTimeTap: Bool = true
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    
    private lazy var citationTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = primaryColor
        tv.textColor = UIColor.lightGray
        tv.text = AppStrings.Reference.citationExample
        tv.textContainerInset = UIEdgeInsets.zero
        //tf.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        tv.textContainer.lineFragmentPadding = .zero
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.layer.cornerRadius = 7
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    init(reference: Reference? = nil) {
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        citationTextView.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        navigationBarAppearance.configureWithOpaqueBackground()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance = barButtonItemAppearance
        
        navigationBarAppearance.shadowColor = separatorColor
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
        citationTextView.resignFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubviews(stack, citationTextView, separatorView)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            citationTextView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            citationTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            citationTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            separatorView.topAnchor.constraint(equalTo: citationTextView.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: citationTextView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: citationTextView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
        
        titleLabel.text = AppStrings.Reference.citationTitle
        contentLabel.text = AppStrings.Reference.citationEvidence
        citationTextView.delegate = self
        citationTextView.inputAccessoryView = addDiagnosisToolbar()
        cancelButton.isHidden = true
        
        if let reference = reference {
            citationTextView.text = ""
            citationTextView.tintColor = primaryColor
            citationTextView.textColor = primaryColor
            firstTimeTap.toggle()
            citationTextView.text = reference.referenceText
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
        }
    }
    
    private func addDiagnosisToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(addReference), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(removeReference), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = .systemFont(ofSize: 14, weight: .semibold)
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.add, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = .systemFont(ofSize: 14, weight: .regular)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Actions.remove, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        referenceButton.configuration = shareConfig
        
        cancelButton.configuration = cancelConfig
        let rightButton = UIBarButtonItem(customView: referenceButton)

        let leftButton = UIBarButtonItem(customView: cancelButton)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        
        referenceButton.isEnabled = false
                
        return toolbar
    }
    
    @objc func addReference() {
        guard let text = citationTextView.text, !text.isEmpty else { return }
        let reference = Reference(option: .citation, referenceText: text)
        NotificationCenter.default.post(name: NSNotification.Name("PostReference"), object: nil, userInfo: ["reference": reference])
        dismiss(animated: true)
    }
    
    @objc func removeReference() {
        delegate?.didTapDeleteReference()
        dismiss(animated: true)
    }

    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.resizeScrollViewContentSize()
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 20,
                                                       right: 0)
            }
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollView.resizeScrollViewContentSize()
        }
    }
}

extension AddAuthorReferenceViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == AppStrings.Reference.citationExample  {
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if firstTimeTap {
            if let char = textView.text.first {
                textView.text = String(char)
                textView.isUserInteractionEnabled = true
                textView.tintColor = primaryColor
                textView.textColor = primaryColor
                firstTimeTap.toggle()
            }
        }
        
        referenceButton.isEnabled = textView.text.isEmpty ? false : true
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        scrollView.resizeScrollViewContentSize()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if firstTimeTap && textView.text == AppStrings.Reference.citationExample {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
}


