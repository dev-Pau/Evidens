//
//  UIMenu+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/8/23.
//

import UIKit

/// An extension of UIMenu.
extension UIMenu {
    
    /// Creates a contextual menu for a post cell based on the user's role and post ownership.
    /// - Parameters:
    ///   - cell: The UICollectionViewCell associated with the menu. (Optional)
    ///   - viewModel: The PostViewModel containing information about the post.
    ///   - delegate: The delegate object conforming to the PostCellDelegate protocol.
    /// - Returns: A UIMenu instance with relevant UIAction items for the post cell.
    static func createPostMenu(_ cell: UICollectionViewCell? = nil, for viewModel: PostViewModel, delegate: PostCellDelegate) -> UIMenu? {
        guard let uid = UserDefaults.getUid() else { return nil }
        
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
    
    /// Creates a contextual menu for a clinical case cell based on the user's role and case phase.
    /// - Parameters:
    ///   - cell: The UICollectionViewCell associated with the menu. (Optional)
    ///   - viewModel: The CaseViewModel containing information about the clinical case.
    ///   - delegate: The delegate object conforming to the CaseCellDelegate protocol.
    /// - Returns: A UIMenu instance with relevant UIAction items for the clinical case cell.
    static func createCaseMenu(_ cell: UICollectionViewCell? = nil, for viewModel: CaseViewModel, delegate: CaseCellDelegate) -> UIMenu? {
        guard let uid = UserDefaults.getUid() else { return nil }
        
        var menuItems = [UIAction]()
        
        if uid == viewModel.clinicalCase.uid {

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
    
    /// Creates a primary contextual menu for a clinical case cell with limited options.
    /// - Parameters:
    ///   - cell: The UICollectionViewCell associated with the menu. (Optional)
    ///   - viewModel: The CaseViewModel containing information about the clinical case.
    ///   - delegate: The delegate object conforming to the CaseCellDelegate protocol.
    /// - Returns: A UIMenu instance with a single UIAction for reporting the clinical case.
    static func createPrimaryCaseMenu(_ cell: UICollectionViewCell? = nil, for viewModel: CaseViewModel, delegate: CaseCellDelegate) -> UIMenu? {

        let reportAction = UIAction(title: CaseMenu.report.title, image: CaseMenu.report.image) { _ in
            delegate.clinicalCase(didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
        }

        return UIMenu(title: "", children: [reportAction])
    }
}
