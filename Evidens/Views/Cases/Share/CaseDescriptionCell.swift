//
//  CaseDescriptionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import UIKit

protocol CaseDescriptionCellDelegate: AnyObject {
    func didUpdateDescription(_ text: String, withHashtags hashtags: [String])
}

class CaseDescriptionCell: UICollectionViewCell {
    weak var delegate: CaseDescriptionCellDelegate?
    private var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    private let charCount = 1300
    private var detailsLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Share.description
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Case.Share.description
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.tintColor = primaryColor
        tv.textColor = .label
        tv.delegate = self
        tv.autocorrectionType = .no
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private lazy var titleTextTracker = CharacterTrackerView(withMaxCharacters: charCount)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func configure() {
        addSubviews(detailsLabel, descriptionTextView, titleTextTracker, separatorView)
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            detailsLabel.bottomAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: -2),
            detailsLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            
            titleTextTracker.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor),
            titleTextTracker.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            titleTextTracker.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            titleTextTracker.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        titleTextTracker.isHidden = true
        descriptionTextView.delegate = self
    }
    
    func resignTextResponder() {
        descriptionTextView.resignFirstResponder()
    }
}

extension CaseDescriptionCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleTextTracker.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleTextTracker.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = descriptionTextView.text else {
            delegate?.didUpdateDescription("", withHashtags: [])
            return
        }
        let count = text.count
        
        if count != 0 {
            detailsLabel.isHidden = false
        } else {
            detailsLabel.isHidden = true
        }
        
        if count > charCount {
            descriptionTextView.deleteBackward()
            return
        }
        
        //let size = CGSize(width: frame.width, height: .infinity)
        //let estimatedSize = textView.sizeThatFits(size)
        let hashtags = textView.hashtags()
        delegate?.didUpdateDescription(text, withHashtags: hashtags)
        titleTextTracker.updateTextTracking(toValue: count)
    }
}
