//
//  UIMenu+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/8/23.
//

import UIKit

extension UIMenu {
    
    static func createPostMenu(_ cell: UICollectionViewCell? = nil, for viewModel: PostViewModel, delegate: HomeCellDelegate) -> UIMenu? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        
        var menuItems = [UIAction]()
        
        if uid == viewModel.post.uid {
            
            let deleteAction = UIAction(title: PostMenu.delete.title, image: PostMenu.delete.image, attributes: .destructive) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .delete)
            }
            
            let editAction = UIAction(title: PostMenu.edit.title, image: PostMenu.edit.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .edit)
            }
            
            menuItems.append(deleteAction)
            menuItems.append(editAction)
        } else {
            
            let reportAction = UIAction(title: PostMenu.report.title, image: PostMenu.report.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .report)
            }
            
            menuItems.append(reportAction)
        }
        
        if viewModel.reference != nil {
            let referenceAction = UIAction(title: PostMenu.reference.title, image: PostMenu.reference.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .reference)
            }
            menuItems.append(referenceAction)
        }
        
        return UIMenu(title: "", children: menuItems)
    }
}
