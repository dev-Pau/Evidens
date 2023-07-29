//
//  AddReportContextViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

protocol AddReportContextViewControllerDelegate: AnyObject {
    func didAddReport(_ report: Report)
}

class AddReportContextViewController: UIViewController {
    
    weak var delegate: AddReportContextViewControllerDelegate?
    private var report: Report
    
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
    
    private lazy var contextTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = primaryColor
        tv.textColor = UIColor.lightGray
        tv.text = AppStrings.Report.Submit.details
        tv.textContainerInset = UIEdgeInsets.zero
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
    
    private let contextDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reportContextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Actions.skip, attributes: container)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contextTextView.becomeFirstResponder()
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
        
    }
    
    init(report: Report) {
        self.report = report
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        appearance.configureWithOpaqueBackground()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        
        contextTextView.delegate = self
        contextTextView.inputAccessoryView = addReportToolbar()
        cancelButton.isHidden = true
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds

        let stack = UIStackView(arrangedSubviews: [titleLabel, contextDescription])
        stack.axis = .vertical
    
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, contextTextView, separatorView)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contextTextView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            contextTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            contextTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: contextTextView.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: contextTextView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contextTextView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
        
        titleLabel.text = AppStrings.Report.Submit.detailsTitle
        contextDescription.text = AppStrings.Report.Submit.detailsContent
        contextTextView.delegate = self
        
        if let content = report.content {
            contextTextView.text = ""
            contextTextView.tintColor = primaryColor
            contextTextView.textColor = primaryColor
            firstTimeTap.toggle()
            contextTextView.text = content
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
        }
    }
    
    private func addReportToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        appearance.backgroundColor = .systemBackground
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
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

    @objc func handleContinueReport() {
        let controller = ReportTargetViewController(report: report)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleContinue() {
        guard !contextTextView.text.isEmpty else {
            return
        }
        
        report.content = contextTextView.text
        delegate?.didAddReport(report)
        dismiss(animated: true)
    }
    
    @objc func handleRemove() {
        report.content = nil
        delegate?.didAddReport(report)
        dismiss(animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.resizeContentSize()
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
            scrollView.resizeContentSize()
        }
    }
}


extension AddReportContextViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == AppStrings.Report.Submit.details {
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
        
        let count = textView.text.count
        if count > 300 { contextTextView.deleteBackward() }
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        scrollView.resizeContentSize()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if firstTimeTap && textView.text == AppStrings.Report.Submit.details {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
}




