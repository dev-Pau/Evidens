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

        if viewModel.reference != nil {
            let referenceAction = UIAction(title: PostMenu.reference.title, image: PostMenu.reference.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .reference)
            }
            
            menuItems.append(referenceAction)
        }
        
        if uid == viewModel.post.uid {
            
            let deleteAction = UIAction(title: PostMenu.delete.title, image: PostMenu.delete.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .delete)
            }
            
            let editAction = UIAction(title: PostMenu.edit.title, image: PostMenu.edit.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .edit)
            }
            
            menuItems.append(editAction)
            menuItems.append(deleteAction)
        } else {
            
            let reportAction = UIAction(title: PostMenu.report.title, image: PostMenu.report.image) { _ in
                delegate.cell(didTapMenuOptionsFor: viewModel.post, option: .report)
            }
            
            menuItems.append(reportAction)
        }

        return UIMenu(title: "", children: menuItems)
    }
    
    static func createCaseMenu(_ cell: UICollectionViewCell? = nil, for viewModel: CaseViewModel, delegate: CaseCellDelegate) -> UIMenu? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        
        var menuItems = [UIAction]()
        
        if uid == viewModel.clinicalCase.uid {
            // Owner
            if viewModel.clinicalCase.phase == .solved {
                
                let deleteAction = UIAction(title: CaseMenu.delete.title, image: CaseMenu.delete.image) { _ in
                    delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                }
                
                menuItems.append(deleteAction)

            } else {
                let deleteAction = UIAction(title: CaseMenu.delete.title, image: CaseMenu.delete.image) { _ in
                    delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                }
                
                let revisionAction = UIAction(title: CaseMenu.revision.title, image: CaseMenu.revision.image) { _ in
                    delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .revision)
                }
                
                let solveAction = UIAction(title: CaseMenu.solve.title, image: CaseMenu.solve.image) { _ in
                    delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .solve)
                }
                
                menuItems.append(revisionAction)
                menuItems.append(solveAction)
                menuItems.append(deleteAction)
            }
        } else {
            let reportAction = UIAction(title: CaseMenu.report.title, image: CaseMenu.report.image) { _ in
                delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
            }
            
            menuItems.append(reportAction)
        }
        
        return UIMenu(title: "", children: menuItems)
    }
    
    static func createPrimaryCaseMenu(_ cell: UICollectionViewCell? = nil, for viewModel: CaseViewModel, delegate: CaseCellDelegate) -> UIMenu? {

        let reportAction = UIAction(title: CaseMenu.report.title, image: CaseMenu.report.image) { _ in
            delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
        }

        return UIMenu(title: "", children: [reportAction])
    }
}
