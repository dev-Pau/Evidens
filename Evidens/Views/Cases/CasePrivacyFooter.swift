//
//  CasePrivacyFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/4/23.
//

import UIKit

protocol CasePrivacyFooterDelegate: AnyObject {
    func didTapPatientPrivacy()
}

class CasePrivacyFooter: UICollectionReusableView {
    
    weak var delegate: CasePrivacyFooterDelegate?
    
    private lazy var privacyContent: NSMutableAttributedString = {
        
        let font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        let aString = NSMutableAttributedString(string: AppStrings.Content.Case.Share.privacy)
        aString.addAttribute(NSAttributedString.Key.font, value: font, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.privacy))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: K.Colors.primaryGray, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.privacy))
        
        
        aString.addAttribute(NSAttributedString.Key.font, value: font, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.patientPrivacyPolicy))
        aString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.patientPrivacy, range: (aString.string as NSString).range(of: AppStrings.Content.Case.Share.patientPrivacyPolicy))
        return aString
    }()
    
    private lazy var privacyTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.primaryColor]
        tv.textColor = K.Colors.primaryGray
        tv.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        tv.attributedText = privacyContent
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(privacyTextView)
        
        NSLayoutConstraint.activate([
            privacyTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            privacyTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            privacyTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            privacyTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
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
