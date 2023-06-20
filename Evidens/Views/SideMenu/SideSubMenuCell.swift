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
        label.font = .systemFont(ofSize: 15, weight: .semibold)
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
        
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20),
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10)
        ])
    }
    
    func set(option: SideSubMenu) {
        label.text = option.title
     
    }
    
    func test() {
        let rotationAngle: CGFloat = self.clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2
        let tintColor = (self.clockwise ? separatorColor : primaryColor)!
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.clockwise {
                self.chevron.transform = self.chevron.transform.rotated(by: 2 * -rotationAngle)
            } else {
                self.chevron.transform = CGAffineTransform(rotationAngle:  -rotationAngle)
                self.chevron.transform = CGAffineTransform(rotationAngle:  2 * rotationAngle)
            }
            
            self.chevron.tintColor = tintColor
        }) { _ in
            self.clockwise.toggle()
        }
        
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     //self.chevron.transform = self.chevron.transform.concatenating(CGAffineTransform(translationX: self.chevron.bounds.width, y: -self.chevron.bounds.height))
     
     self.chevron.image = self.chevron.image?.withTintColor(tintColor!)
     
     */
}