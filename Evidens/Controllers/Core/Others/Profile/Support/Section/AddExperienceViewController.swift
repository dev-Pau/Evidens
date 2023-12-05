//
//  AddExperienceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

protocol AddExperienceViewControllerDelegate: AnyObject {
    func didAddExperience(_ experience: Experience)
    func didDeleteExperience(_ experience: Experience)
}

class AddExperienceViewController: UIViewController {
    
    weak var delegate: AddExperienceViewControllerDelegate?
    private var viewModel = ExperienceViewModel()
    private var userIsEditing = false

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Sections.experienceContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.role, secureTextEntry: false, title: AppStrings.Sections.role)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let companyTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.company, secureTextEntry: false, title: AppStrings.Sections.company)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(.secondaryLabel)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleDate), for: .touchUpInside)
        return button
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.text = AppStrings.Sections.work
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let startTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.startDate, secureTextEntry: false, title: AppStrings.Sections.startDate)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let endTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.endDate, secureTextEntry: false, title: AppStrings.Sections.endDate)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
       
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Alerts.Title.deletePatent,  attributes: container)

        button.configuration?.baseForegroundColor = .systemRed
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDatePicker()
        configureUI()
    }
    
    init(experience: Experience? = nil) {
        viewModel.set(experience: experience)
        if let _ = experience {
            userIsEditing = true
        } else {
            userIsEditing = false
        }
      
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: userIsEditing ? AppStrings.Global.save : AppStrings.Global.add, style: .done, target: self, action: #selector(handleDone))
        deleteButton.isHidden = userIsEditing ? false : true
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    private func configureDatePicker() {
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        startToolbar.scrollEdgeAppearance = appearance
        startToolbar.standardAppearance = appearance
        
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddStartDate))
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddEndDate))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        startToolbar.setItems([flexibleSpace, startDoneButton], animated: true)
        endToolbar.setItems([flexibleSpace, endDoneButton], animated: true)
        
        startTextField.inputAccessoryView = startToolbar
        endTextField.inputAccessoryView = endToolbar
        
        startTextField.inputView = startDatePicker
        endTextField.inputView = endDatePicker
    }
    
    private func configureUI() {
        title = AppStrings.Sections.experienceTitle
       
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, roleTextField, companyTextField, dateLabel, dateButton, startTextField, endTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            dateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateButton.heightAnchor.constraint(equalToConstant: 22),
            dateButton.widthAnchor.constraint(equalToConstant: 22),

            dateLabel.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateButton.trailingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            roleTextField.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 20),
            roleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            roleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            companyTextField.topAnchor.constraint(equalTo: roleTextField.bottomAnchor, constant: 20),
            companyTextField.leadingAnchor.constraint(equalTo: roleTextField.leadingAnchor),
            companyTextField.trailingAnchor.constraint(equalTo: roleTextField.trailingAnchor),
            
            startTextField.topAnchor.constraint(equalTo: companyTextField.bottomAnchor, constant: 20),
            startTextField.leadingAnchor.constraint(equalTo: companyTextField.leadingAnchor),
            startTextField.trailingAnchor.constraint(equalTo: roleTextField.trailingAnchor),
            
            endTextField.topAnchor.constraint(equalTo: startTextField.bottomAnchor, constant: 20),
            endTextField.trailingAnchor.constraint(equalTo: roleTextField.trailingAnchor),
            endTextField.leadingAnchor.constraint(equalTo: roleTextField.leadingAnchor),
        ])
        
        if userIsEditing {
            scrollView.addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                deleteButton.topAnchor.constraint(equalTo: endTextField.bottomAnchor, constant: 20)
            ])
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none

            if let start = viewModel.start {
                startTextField.text = formatter.string(from: Date(timeIntervalSince1970: start))
            }
            
            if let end = viewModel.end {
                endTextField.text = formatter.string(from: Date(timeIntervalSince1970: end))
            }
            
            dateButton.configuration?.image = viewModel.dateImage
            
            endTextField.isHidden = viewModel.isCurrentExperience ? true : false
            endTextField.text = viewModel.isCurrentExperience ? nil : endTextField.text
            
            roleTextField.text = viewModel.role
            companyTextField.text = viewModel.company
            
            endTextField.textFieldDidChange()
            startTextField.textFieldDidChange()
            roleTextField.textFieldDidChange()
            companyTextField.textFieldDidChange()
        }
        
        roleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func handleDone() {
        guard viewModel.isValid else { return }
        showProgressIndicator(in: view)
        if userIsEditing {
            DatabaseManager.shared.editExperience(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let experience = strongSelf.viewModel.experience else { return }
                    strongSelf.delegate?.didAddExperience(experience)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            DatabaseManager.shared.addExperience(viewModel: viewModel) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                switch result {
                    
                case .success(let experience):
                    strongSelf.delegate?.didAddExperience(experience)
                    strongSelf.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
    
    @objc func handleAddStartDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        startTextField.text = formatter.string(from: startDatePicker.date)
        startTextField.textFieldChanged()
        
        let timeInterval = startDatePicker.date.timeIntervalSince1970
        viewModel.set(start: timeInterval)
        
        isValid()
        
        view.endEditing(true)
    }
    
    @objc func handleAddEndDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        endTextField.text = formatter.string(from: endDatePicker.date)
        endTextField.textFieldChanged()
        
        let timeInterval = endDatePicker.date.timeIntervalSince1970
        viewModel.set(end: timeInterval)
        
        isValid()
        
        view.endEditing(true)
    }
    
    @objc func toggleDate() {
        viewModel.toggleExperience()
        dateButton.configuration?.image = viewModel.dateImage
        
        endTextField.isHidden = viewModel.isCurrentExperience ? true : false
        endTextField.text = viewModel.isCurrentExperience ? nil : endTextField.text
        endTextField.textFieldChanged()
        isValid()
    }
    
    
    @objc func textFieldDidChange(_ textField: InputTextField) {
        if textField == roleTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(role: text)
            } else {
                viewModel.set(role: nil)
            }
        } else if textField == companyTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(company: text)
            } else {
                viewModel.set(company: nil)
            }
        }
        
        isValid()
    }

    @objc func handleDelete() {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteExperience, withMessage: AppStrings.Alerts.Subtitle.deleteExperience, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            DatabaseManager.shared.deleteExperience(viewModel: strongSelf.viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let experience = strongSelf.viewModel.experience else { return }
                    strongSelf.delegate?.didDeleteExperience(experience)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
