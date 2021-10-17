//
//  FeedMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

private let reuseIdentifier = "FeedMenuCell"

class FeedMenuViewController: UIViewController {
    
    //MARK: - Properties
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 80, height: UIScreen.main.bounds.height)
        scrollView.backgroundColor = .green
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: UIScreen.main.bounds.height)
        return scrollView
    }()
    
    private let passwordCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        
        scrollView.addSubview(passwordCheckmarkButton)
        passwordCheckmarkButton.centerY(inView: scrollView)
        passwordCheckmarkButton.centerX(inView: scrollView)

    }

    //MARK: - Handlers

}
