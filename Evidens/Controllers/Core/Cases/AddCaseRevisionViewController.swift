//
//  AddCaseUpdateViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/8/22.
//

import UIKit

class AddCaseRevisionViewController: UIViewController {

    private var viewModel: AddCaseRevisionViewModel
    
    private var maxCount: Int = 600
    
    private var textButton: UIButton!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        label.text = AppStrings.Content.Case.Revision.progressContent
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        return label
    }()
    
    private let titleTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Content.Case.Share.title, secureTextEntry: false, title: AppStrings.Content.Case.Share.title)
        tf.textColor = .label
        tf.tintColor = .label
        return tf
    }()

    private lazy var contentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Case.Share.description
        let font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
        tv.textColor = .label
        tv.tintColor = .label
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = AppStrings.Content.Case.Share.description
        label.alpha = 0
        return label
    }()
    
    private let bottomSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    
    init(clinicalCase: Case) {
        self.viewModel = AddCaseRevisionViewModel(clinicalCase: clinicalCase)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
     private func configureNavigationBar() {
         let appearance = UINavigationBarAppearance.secondaryAppearance()
         navigationController?.navigationBar.standardAppearance = appearance
         navigationController?.navigationBar.scrollEdgeAppearance = appearance
         
         addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
         
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
        
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.add, style: .done, target: self, action: #selector(handleAddRevision))
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
         
         contentTextView.inputAccessoryView = addCaseToolbar()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        
        view.addSubview(scrollView)
        scrollView.addSubviews(profileImageView, contentLabel, titleTextField, descriptionLabel, contentTextView, bottomSeparatorView)
        
        let imageSize: CGFloat = UIDevice.isPad ? 60 : 40

        contentTextView.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        profileImageView.layer.cornerRadius = imageSize / 2
        contentTextView.placeholderLabel.textColor = UIColor.tertiaryLabel
        
        if viewModel.clinicalCase.privacy == .anonymous {
            profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            profileImageView.addImage(forUrl: UserDefaults.getImage(), size: imageSize)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: UIDevice.isPad ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Content.verticalPadding),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),

            profileImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 15),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            titleTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            titleTextField.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            contentTextView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),

            bottomSeparatorView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
        
        updateTextCount(0)
    }

    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    private func addCaseToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        textButton = UIButton(type: .system)
        textButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        var textConfig = UIButton.Configuration.plain()
        textConfig.baseForegroundColor = .label
        textConfig.buttonSize = .mini
        textConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)

        textButton.configuration = textConfig
       
        let midButton = UIBarButtonItem(customView: textButton)

        toolbar.setItems([.flexibleSpace(), midButton, .flexibleSpace()], animated: false)
        toolbar.layoutIfNeeded()

        return toolbar
    }

    @objc func handleAddRevision() {
        contentTextView.resignFirstResponder()
        
        viewModel.addRevision { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.contentTextView.becomeFirstResponder()
                }
            } else {
                strongSelf.dismiss(animated: true)
                
                let popupView = PopUpBanner(title: AppStrings.PopUp.caseRevision, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
            }
        }
    }
    
    @objc func handleDismiss() {
        if viewModel.isValid {
            displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.titleTextField.resignFirstResponder()
                strongSelf.contentTextView.resignFirstResponder()
                strongSelf.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateForm()
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

extension AddCaseRevisionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let strongSelf = self else { return }
            if !textView.text.isEmpty {
                strongSelf.descriptionLabel.alpha = 1
            } else {
                strongSelf.descriptionLabel.alpha = 0
            }
        }
        
        let count = textView.text.count
        if count > maxCount {
            textView.deleteBackward()
        } else {
            updateTextCount(count)
        }
        
        textView.sizeToFit()
        scrollView.resizeContentSize()
        
        viewModel.content = textView.text
        updateForm()
    }
    
    
    private func updateTextCount(_ count: Int) {
        
        var tContainer = AttributeContainer()
        tContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        tContainer.foregroundColor = K.Colors.primaryGray
        
        let remainingCount = maxCount - count
        textButton.configuration?.attributedTitle = AttributedString("\(remainingCount)", attributes: tContainer)
    }
}
