//
//  CaseResolvedViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/22.
//

import UIKit

protocol CaseDiagnosisViewControllerDelegate: AnyObject {
    func handleAddDiagnosis(_ text: String)
}

class CaseDiagnosisViewController: UIViewController {
    
    weak var delegate: CaseDiagnosisViewControllerDelegate?
    
    private var previousValue: Int = 0
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Help the community and get more engagement by adding a diagnose about your conclusions"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = blackColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var diagnosisTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add a diagnosis here..."
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = blackColor
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var diagnosisView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let circularShapeTracker = CircularShapeTextTracker(withSteps: 500)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circularShapeTracker.addShapeIndicator(in: diagnosisView)
    }


    private func configureNavigationBar() {
        title = "Diagnosis details"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = blackColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddDiagnosis))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.addSubviews(textLabel, diagnosisTextView, diagnosisView)

        diagnosisTextView.delegate = self
        diagnosisView.isHidden = true
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 13),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -13),
            
            diagnosisTextView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 10),
            diagnosisTextView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -2),
            diagnosisTextView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            diagnosisTextView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2 - 200),

            diagnosisView.topAnchor.constraint(equalTo: diagnosisTextView.bottomAnchor, constant: 3),
            diagnosisView.trailingAnchor.constraint(equalTo: diagnosisTextView.trailingAnchor),
            diagnosisView.heightAnchor.constraint(equalToConstant: 27),
            diagnosisView.widthAnchor.constraint(equalToConstant: 27)
             
        ])
    }
    
    
    @objc func handleAddDiagnosis() {
        delegate?.handleAddDiagnosis(diagnosisTextView.text)
        dismiss(animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CaseDiagnosisViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        
        navigationItem.rightBarButtonItem?.isEnabled = count > 0 ? true : false
        
        if previousValue == 0 {
            circularShapeTracker.updateShapeIndicator(toValue: count, previousValue: 0)
        } else {
            circularShapeTracker.updateShapeIndicator(toValue: count, previousValue: previousValue)
        }
        
        previousValue = count
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        diagnosisView.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        diagnosisView.isHidden = true
    }
}
