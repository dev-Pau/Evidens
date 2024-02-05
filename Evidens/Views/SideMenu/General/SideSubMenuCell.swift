//
//  SideSubMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/6/23.
//

import UIKit

class SideSubMenuCell: UICollectionViewCell {
    
    private var NSLayoutHeightConstraint: NSLayoutConstraint!
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title2, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.downChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = separatorColor
        return iv
    }()
    
    private var clockwise: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews(label, chevron)
        
        let size: CGFloat = UIDevice.isPad ? 25 : 20
        
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chevron.widthAnchor.constraint(equalToConstant: size),
            chevron.heightAnchor.constraint(equalToConstant: size),
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10)
        ])
    }
    
    func set(option: SideSubMenu) {
        label.text = option.title
     
    }
    
    func toggleChevron() {
        let rotationAngle: CGFloat = clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2
        let tintColor = (clockwise ? separatorColor : primaryColor)
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.clockwise {
                strongSelf.chevron.transform = strongSelf.chevron.transform.rotated(by: 2 * -rotationAngle)
            } else {
                strongSelf.chevron.transform = CGAffineTransform(rotationAngle:  -rotationAngle)
                strongSelf.chevron.transform = CGAffineTransform(rotationAngle:  2 * rotationAngle)
            }
            
            strongSelf.chevron.tintColor = tintColor
        }) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.isUserInteractionEnabled = true
            strongSelf.clockwise.toggle()
        }
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
