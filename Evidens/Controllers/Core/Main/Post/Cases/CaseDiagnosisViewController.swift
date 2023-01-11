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
    
    var stageIsUpdating: Bool = false
    var diagnosisIsUpdating: Bool = false
    var caseId: String = ""
    
    private var diagnosisText: String
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Help the community and get more engagement by adding a diagnose about your conclusions"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var diagnosisTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add your diagnosis here..."
        //tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        //tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        tv.tintColor = primaryColor
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    let textTracker = CharacterTextTracker(withMaxCharacters: 1000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureUI()
    }
    
    init(diagnosisText: String) {
        self.diagnosisText = diagnosisText
        textTracker.updateTextTracking(toValue: diagnosisText.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func configureNavigationBar() {
        title = "Diagnosis details"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        let rightBarButtonText = stageIsUpdating || diagnosisIsUpdating ? "Skip" : "Add"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonText, style: .done, target: self, action: #selector(handleAddDiagnosis))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = stageIsUpdating || diagnosisIsUpdating ? true : false
    }
    
    private func configureUI() {
        view.addSubviews(profileImageView, textLabel, diagnosisTextView, textTracker, separatorView)
        
        textTracker.isHidden = true
        
        diagnosisTextView.placeholderLabel.text = diagnosisText.count > 0 ? "" : "Add your diagnosis here..."
        diagnosisTextView.text = diagnosisText
        diagnosisTextView.delegate = self
        
        profileImageView.layer.cornerRadius = 45 / 2
        profileImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        
        NSLayoutConstraint.activate([
           
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -13),
            
            separatorView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            profileImageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 13),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),

            diagnosisTextView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 2),
            diagnosisTextView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            diagnosisTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            diagnosisTextView.heightAnchor.constraint(equalToConstant: 127),

            textTracker.topAnchor.constraint(equalTo: diagnosisTextView.bottomAnchor, constant: 3),
            textTracker.trailingAnchor.constraint(equalTo: diagnosisTextView.trailingAnchor),
            textTracker.leadingAnchor.constraint(equalTo: diagnosisTextView.leadingAnchor),
            textTracker.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    @objc func handleAddDiagnosis() {
        if stageIsUpdating || diagnosisIsUpdating {
            
            if diagnosisTextView.text.count == 0 {
                dismissDiagnosisAlert {
                    // User changes state to solved without diagnosis
                    CaseService.uploadCaseStage(withCaseId: self.caseId) { uploaded in
                        if uploaded {
                            self.delegate?.handleAddDiagnosis("")
                            let popUpView = METopPopupView(title: "Case changed to solved", image: "checkmark")
                            popUpView.showTopPopup(inView: self.view)
                            self.dismiss(animated: true)
                            return
                        }
                    }
                }
            } else {
                // Clinical Case has diagnosis, update the case with it
                showLoadingView()
                CaseService.uploadCaseDiagnosis(withCaseId: caseId, withDiagnosis: diagnosisTextView.text) { uploaded in
                    self.dismissLoadingView()
                    if uploaded {
                        // Diagnosis updated, update previous view controllers
                        self.delegate?.handleAddDiagnosis(self.diagnosisTextView.text)
                        let popUpView = METopPopupView(title: "Case changed to solved", image: "checkmark")
                        popUpView.showTopPopup(inView: self.view)

                        self.dismiss(animated: true)
                    } else {
                        print("couldn't add diagnosis")
                    }
                }
            }

        } else {
            delegate?.handleAddDiagnosis(diagnosisTextView.text)
            dismiss(animated: true)
        }

    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CaseDiagnosisViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        if stageIsUpdating || diagnosisIsUpdating {
            navigationItem.rightBarButtonItem?.title = count > 0 ? "Update" : "Skip"
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = count > 0 ? true : false
        }
        textTracker.updateTextTracking(toValue: count)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textTracker.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textTracker.isHidden = true
    }
}
