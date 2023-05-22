//
//  CaseDescriptionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import UIKit

protocol CaseDescriptionCellDelegate: AnyObject {
    func didUpdateDescription(_ text: String)
}

class CaseDescriptionCell: UICollectionViewCell {
    weak var delegate: CaseDescriptionCellDelegate?
    private var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    
    private var detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = " Description"
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        tv.tintColor = primaryColor
        tv.isScrollEnabled = true
        tv.backgroundColor = .quaternarySystemFill
        tv.layer.cornerRadius = 7
        tv.autocorrectionType = .no
        tv.textContainer.maximumNumberOfLines = 0
        tv.placeHolderShouldCenter = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private var titleTextTracker = CharacterTextTracker(withMaxCharacters: 1300)
    
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
        
        
        
        
        descriptionTextViewHeightConstraint = descriptionTextView.heightAnchor.constraint(equalToConstant: (descriptionTextView.font?.lineHeight ?? 0.0) * 7)
        descriptionTextViewHeightConstraint.priority = .required // Make sure the height constraint is required
        descriptionTextViewHeightConstraint.isActive = true
        //descriptionTextView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
}

extension CaseDescriptionCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleTextTracker.isHidden = false
        delegate?.didUpdateDescription(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleTextTracker.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = descriptionTextView.text else {
            delegate?.didUpdateDescription(String())
            return
        }
        let count = text.count
        
        if count != 0 {
            detailsLabel.isHidden = false
        } else {
            detailsLabel.isHidden = true
        }
        
        if count > 1300 {
            descriptionTextView.deleteBackward()
            return
        }
        
        /*
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        descriptionTextViewHeightConstraint.constant = estimatedSize.height
        //descriptionTextView.invalidateIntrinsicContentSize()
        let heighConstraint = heightAnchor.constraint(equalToConstant: estimatedSize.height)
        heighConstraint.priority = .defaultHigh
        heighConstraint.isActive = true
        
        */
        /*
         descriptionTextView.constraints.forEach { constraint in
         if constraint.firstAttribute == .height {
         constraint.constant = estimatedSize.height
         setNeedsLayout()
         }
         }
         */
        delegate?.didUpdateDescription(text)
        titleTextTracker.updateTextTracking(toValue: count)
        
    }
}
