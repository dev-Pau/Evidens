//
//  AddReferenceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class AddAuthorReferenceViewController: UIViewController {
    
    private let controller: AddPostViewController
    
    private var maxCount: Int = 400
    
    weak var delegate: AddWebLinkReferenceDelegate?
    private var reference: Reference?
    
    private var referenceButton: UIButton!
    private var cancelButton: UIButton!
    private var textButton: UIButton!
    
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
        label.font = UIFont.addFont(size: 25, scaleStyle: .largeTitle, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private lazy var citationTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = K.Colors.primaryColor
        tv.textColor = UIColor.lightGray
        tv.text = AppStrings.Reference.citationExample
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        tv.isScrollEnabled = false
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.delegate = self
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
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
    
    init(controller: AddPostViewController, reference: Reference? = nil) {
        self.controller = controller
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
        delegate = controller
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
       
        citationTextView.resignFirstResponder()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubviews(stack, citationTextView, separatorView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
            citationTextView.tintColor = K.Colors.primaryColor
            citationTextView.textColor = K.Colors.primaryColor
            firstTimeTap.toggle()
            citationTextView.text = reference.referenceText
            updateTextCount(citationTextView.text.count)
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
        } else {
            updateTextCount(0)
        }
    }
    
    private func addDiagnosisToolbar() -> UIToolbar {
        let toolbar = UIToolbar()

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let appearance = UIToolbarAppearance()

        appearance.configureWithOpaqueBackground()
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance

        textButton = UIButton(type: .system)
        textButton.translatesAutoresizingMaskIntoConstraints = false

        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(addReference), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(removeReference), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = K.Colors.primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .semibold, scales: false)
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.add, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Actions.remove, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        
        
        var textConfig = UIButton.Configuration.plain()
        textConfig.baseForegroundColor = .label
        textConfig.buttonSize = .mini
        textConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)

        referenceButton.configuration = shareConfig
        textButton.configuration = textConfig
        cancelButton.configuration = cancelConfig
        
        let rightButton = UIBarButtonItem(customView: referenceButton)
        let midButton = UIBarButtonItem(customView: textButton)
        let leftButton = UIBarButtonItem(customView: cancelButton)

        toolbar.setItems([leftButton, .flexibleSpace(), midButton, .flexibleSpace(), rightButton], animated: false)
        toolbar.layoutIfNeeded()
        
        referenceButton.isEnabled = false
        return toolbar
    }
    
    @objc func addReference() {
        guard let text = citationTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let reference = Reference(option: .citation, referenceText: text.trimmingCharacters(in: .whitespacesAndNewlines))
        delegate?.didAddReference(reference)
        dismiss(animated: true)
    }
    
    @objc func removeReference() {
        delegate?.didTapDeleteReference()
        dismiss(animated: true)
    }

    @objc func handleDismiss() {
        if referenceButton.isEnabled {
            displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.citationTextView.resignFirstResponder()
                strongSelf.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let window = UIWindow.visibleScreen {
            scrollView.resizeContentSize()

            let convertedFrame = view.convert(view.bounds, to: window)
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            
            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                if UIDevice.isPad {
                    var bottomInset = keyboardViewEndFrame.height
                    let windowBottom = UIWindow.visibleScreenBounds.maxY
                    let viewControllerBottom = convertedFrame.maxY
                    let distance = windowBottom - viewControllerBottom
                    bottomInset -= distance
                    scrollView.contentInset.bottom = bottomInset
                } else {
                    scrollView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
                }
            }
            
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollView.resizeContentSize()
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
            textView.isUserInteractionEnabled = true
            textView.tintColor = K.Colors.primaryColor
            textView.textColor = K.Colors.primaryColor
            firstTimeTap.toggle()
            textView.text = textView.text.replacingOccurrences(of: AppStrings.Reference.citationExample, with: "")
        }
        
        let count = textView.text.count
        
        if count > maxCount {
            textView.deleteBackward()
        } else {
            updateTextCount(count)
        }

        referenceButton.isEnabled = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? false : true
        textView.sizeToFit()
        scrollView.resizeContentSize()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if firstTimeTap && textView.text == AppStrings.Reference.citationExample {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    private func updateTextCount(_ count: Int) {
        
        var tContainer = AttributeContainer()
        tContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        tContainer.foregroundColor = K.Colors.primaryGray
        
        let remainingCount = maxCount - count
        textButton.configuration?.attributedTitle = AttributedString("\(remainingCount)", attributes: tContainer)
    }
}


