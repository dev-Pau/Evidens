//
//  AddEducationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit
import JGProgressHUD

protocol AddEducationViewControllerDelegate: AnyObject {
    func didAddEducation(_ education: Education)
    func didDeleteEducation(_ education: Education)
}

class AddEducationViewController: UIViewController {
    
    weak var delegate: AddEducationViewControllerDelegate?

    private let progressIndicator = JGProgressHUD()
    private var viewModel = EducationViewModel()
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
        label.text = AppStrings.Sections.educationContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = AppStrings.Sections.work
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let schoolTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.school, secureTextEntry: false, title: AppStrings.Sections.school)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let degreeTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.degree, secureTextEntry: false, title: AppStrings.Sections.degree)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let fieldTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.field, secureTextEntry: false, title: AppStrings.Sections.field)
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
        container.font = .systemFont(ofSize: 15, weight: .semibold)
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
    
    
    init(education: Education? = nil) {
        viewModel.set(education: education)
        if let _ = education {
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
        title = AppStrings.Sections.educationTitle
      
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, schoolTextField, dateLabel, degreeTextField, fieldTextField, dateButton, startTextField, endTextField)
        
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

            schoolTextField.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 20),
            schoolTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            schoolTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           
            degreeTextField.topAnchor.constraint(equalTo: schoolTextField.bottomAnchor, constant: 20),
            degreeTextField.leadingAnchor.constraint(equalTo: schoolTextField.leadingAnchor),
            degreeTextField.trailingAnchor.constraint(equalTo: schoolTextField.trailingAnchor),

            fieldTextField.topAnchor.constraint(equalTo: degreeTextField.bottomAnchor, constant: 20),
            fieldTextField.leadingAnchor.constraint(equalTo: degreeTextField.leadingAnchor),
            fieldTextField.trailingAnchor.constraint(equalTo: degreeTextField.trailingAnchor),

            startTextField.topAnchor.constraint(equalTo: fieldTextField.bottomAnchor, constant: 20),
            startTextField.leadingAnchor.constraint(equalTo: fieldTextField.leadingAnchor),
            startTextField.trailingAnchor.constraint(equalTo: fieldTextField.trailingAnchor),
            
            endTextField.topAnchor.constraint(equalTo: startTextField.bottomAnchor, constant: 20),
            endTextField.trailingAnchor.constraint(equalTo: startTextField.trailingAnchor),
            endTextField.leadingAnchor.constraint(equalTo: startTextField.leadingAnchor),
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
            
            endTextField.isHidden = viewModel.isCurrentEducation ? true : false
            endTextField.text = viewModel.isCurrentEducation ? nil : endTextField.text
            
            schoolTextField.text = viewModel.school
            degreeTextField.text = viewModel.kind
            fieldTextField.text = viewModel.field
            
            endTextField.textFieldDidChange()
            startTextField.textFieldDidChange()
            schoolTextField.textFieldDidChange()
            degreeTextField.textFieldDidChange()
            fieldTextField.textFieldDidChange()
        }
        
        schoolTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        degreeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fieldTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    @objc func handleDone() {
        guard viewModel.isValid else { return }
        
        progressIndicator.show(in: view)
        
        if userIsEditing {
            DatabaseManager.shared.editEducation(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let education = strongSelf.viewModel.education else { return }
                    strongSelf.delegate?.didAddEducation(education)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            DatabaseManager.shared.addEducation(viewModel: viewModel) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                switch result {
                    
                case .success(let education):
                    strongSelf.delegate?.didAddEducation(education)
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
    
    @objc func textFieldDidChange(_ textField: InputTextField) {
        if textField == schoolTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(school: text)
            } else {
                viewModel.set(school: nil)
            }
        } else if textField == degreeTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(kind: text)
            } else {
                viewModel.set(kind: nil)
            }
        } else if textField == fieldTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(field: text)
            } else {
                viewModel.set(field: nil)
            }
        }
        
        isValid()
    }
    
    @objc func toggleDate() {
        viewModel.toggleEducation()
        dateButton.configuration?.image = viewModel.dateImage
        
        endTextField.isHidden = viewModel.isCurrentEducation ? true : false
        endTextField.text = viewModel.isCurrentEducation ? nil : endTextField.text
        endTextField.textFieldChanged()
        isValid()
    }
    
    
    @objc func handleDelete() {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteEducation, withMessage: AppStrings.Alerts.Subtitle.deleteEducation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.progressIndicator.show(in: strongSelf.view)
            DatabaseManager.shared.deleteEducation(viewModel: strongSelf.viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let education = strongSelf.viewModel.education else { return }
                    strongSelf.delegate?.didDeleteEducation(education)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
