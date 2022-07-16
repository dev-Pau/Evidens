//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI

class VerificationRegistrationViewController: UIViewController {
    
    private var user: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Verification"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle.fill"), style: .done, target: self, action: #selector(handleHelp))
        navigationItem.rightBarButtonItem?.tintColor = blackColor
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc func handleHelp() {
        DispatchQueue.main.async {
            let controller = HelperRegistrationViewController()
            controller.delegate = self
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true)
        }
    }
}

extension VerificationRegistrationViewController: HelperRegistrationViewControllerDelegate {
    
    func didTapContactSupport() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setToRecipients(["support@myevidens.com"])
            controller.mailComposeDelegate = self
            present(controller, animated: true)
        } else {
            print("Device cannot send email")
        }
    }
}

extension FullNameRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}
