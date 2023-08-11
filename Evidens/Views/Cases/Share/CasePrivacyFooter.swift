//
//  CasePrivacyFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/4/23.
//

import UIKit

protocol ShareCaseInformationFooterDelegate: AnyObject {
    func didTapPatientPrivacy()
}

class CasePrivacyFooter: UICollectionReusableView {
    
    weak var delegate: ShareCaseInformationFooterDelegate?
    
    private lazy var privacyContent: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: AppStrings.Content.Case.Share.privacy)
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.privacy))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.privacy))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.patientPrivacyPolicy))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.patientPrivacyPolicy))
        aString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.patientPrivacy, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.patientPrivacyPolicy))
        return aString
    }()
    
    private lazy var privacyTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .secondaryLabel
        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.attributedText = privacyContent
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(privacyTextView, separatorView)
        NSLayoutConstraint.activate([
            privacyTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            privacyTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            privacyTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            privacyTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        privacyTextView.delegate = self
    }
}

extension CasePrivacyFooter: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = url.absoluteString
        if urlString == AppStrings.URL.patientPrivacy {
            delegate?.didTapPatientPrivacy()
            return false
        }
        
        return true
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if textView.selectedTextRange != nil {
                textView.delegate = nil
                textView.selectedTextRange = nil
                textView.delegate = self
            }
        }
    }
}