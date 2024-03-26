//
//  AddReportContextViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

protocol AddReportContextViewControllerDelegate: AnyObject {
    func didAddReport(_ viewModel: ReportViewModel)
}

class AddReportContextViewController: UIViewController {
    
    weak var delegate: AddReportContextViewControllerDelegate?
    private var viewModel: ReportViewModel
    
    private var referenceButton: UIButton!
    private var cancelButton: UIButton!
    private var textButton: UIButton!
    
    private let maxCount = 800
    
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
        label.font = UIFont.addFont(size: 25, scaleStyle: .title2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contextTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = K.Colors.primaryColor
        tv.textColor = UIColor.lightGray
        tv.text = AppStrings.Report.Submit.details
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let contextDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
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
    
    init(viewModel: ReportViewModel) {
        self.viewModel = viewModel
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
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        contextTextView.delegate = self
        contextTextView.inputAccessoryView = addReportToolbar()
        cancelButton.isHidden = true
        addNavigationBarLogo(withImage: AppStrings.Assets.blackLogo, withTintColor: K.Colors.primaryColor)
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contextDescription])
        stack.axis = .vertical
    
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, contextTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Content.verticalPadding),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contextTextView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            contextTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            contextTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
        ])
        
        titleLabel.text = AppStrings.Report.Submit.detailsTitle
        contextDescription.text = AppStrings.Report.Submit.detailsContent
        contextTextView.delegate = self
        
        if let content = viewModel.content {
            contextTextView.text = ""
            contextTextView.tintColor = K.Colors.primaryColor
            contextTextView.textColor = K.Colors.primaryColor
            firstTimeTap.toggle()
            contextTextView.text = content
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
            updateTextCount(contextTextView.text.count)
        } else {
            updateTextCount(0)
        }
    }
   
    private func addReportToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        textButton = UIButton(type: .system)
        textButton.translatesAutoresizingMaskIntoConstraints = false

        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = K.Colors.primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .semibold, scales: false)
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.add, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Actions.remove, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        
        var textConfig = UIButton.Configuration.plain()
        textConfig.baseForegroundColor = .label
        textConfig.buttonSize = .mini
        textConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
      
        textButton.configuration = textConfig
        referenceButton.configuration = shareConfig
        cancelButton.configuration = cancelConfig
        
        let rightButton = UIBarButtonItem(customView: referenceButton)
        let midButton = UIBarButtonItem(customView: textButton)
        let leftButton = UIBarButtonItem(customView: cancelButton)

        toolbar.setItems([leftButton, .flexibleSpace(), midButton, .flexibleSpace(), rightButton], animated: false)
        toolbar.layoutIfNeeded()
        referenceButton.isEnabled = false
                
        return toolbar
    }

    @objc func handleContinueReport() {
        let controller = ReportTargetViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleContinue() {
        viewModel.edit(content: contextTextView.text)
        delegate?.didAddReport(viewModel)
        dismiss(animated: true)
    }
    
    @objc func handleRemove() {
        viewModel.edit(content: nil)
        delegate?.didAddReport(viewModel)
        dismiss(animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let window = UIWindow.visibleScreen {
            
            let convertedFrame = view.convert(view.bounds, to: window)
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            
            scrollView.resizeContentSize()

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
                textView.tintColor = K.Colors.primaryColor
                textView.textColor = K.Colors.primaryColor
                firstTimeTap.toggle()
            }
        }
        
        referenceButton.isEnabled = textView.text.isEmpty ? false : true
        
        let count = textView.text.count
        if count > maxCount {
            contextTextView.deleteBackward()
        } else {
            updateTextCount(count)
        }
        
        textView.sizeToFit()
        scrollView.resizeContentSize()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if firstTimeTap && textView.text == AppStrings.Report.Submit.details {
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




