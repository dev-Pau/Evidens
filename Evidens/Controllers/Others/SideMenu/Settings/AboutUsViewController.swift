//
//  AboutUsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import UIKit

private let headerReuseIdentifier = "HeaderReuseIdentifier"
private let cellReuseIdentifier = "CellReuseIdentifier"
private let footerReuseIdentifier = "FooterReuseIdentifier"

class AboutUsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let aboutUsProgressView = AboutUsProgressView()
    private var aboutUsContentViews = [AboutUsContentView]()
    private let numberOfSegments = 3
    private var loaded: Bool = false
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .semibold, scales: false)

        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.exclamationGreat, attributes: container)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !loaded else { return }
        for index in 0 ..< numberOfSegments {
            let aboutUsContentView = AboutUsContentView()
            aboutUsContentView.frame = CGRect(x: CGFloat(index) * (view.frame.width), y: 35, width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.height - 50 - 20 - 35)
            aboutUsContentView.configure(with: AboutKind.allCases[index])
            scrollView.addSubview(aboutUsContentView)
            aboutUsContentViews.append(aboutUsContentView)
        }
        
        loaded.toggle()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
        

        navigationItem.backBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .done, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    private func configure() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        view.backgroundColor = primaryColor
        scrollView.addSubviews(aboutUsProgressView, continueButton)
        aboutUsProgressView.progressDelegate = self
        NSLayoutConstraint.activate([
            aboutUsProgressView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            aboutUsProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aboutUsProgressView.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            aboutUsProgressView.heightAnchor.constraint(equalToConstant: 30),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        scrollView.contentSize.width = 4 * view.frame.width
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNext() {
        aboutUsProgressView.changeProgress(upwards: true)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let x = recognizer.location(in: view).x
        
        if x > view.frame.width * 0.3 {
            aboutUsProgressView.changeProgress(upwards: true)
        } else {
            aboutUsProgressView.changeProgress(upwards: false)
        }
    }
}

extension AboutUsViewController: AboutUsProgressViewDelegate {
    func timerDidFinish(for index: Int, upwards: Bool) {
        let currentContentOffset = scrollView.contentOffset
        if upwards {
            if index + 1 == numberOfSegments {
                navigationController?.popViewController(animated: true)
            } else {
                let newContentOffset = CGPoint(x: view.frame.width * CGFloat(index + 1), y: currentContentOffset.y)
                scrollView.setContentOffset(newContentOffset, animated: true)
            }
        } else {
            if index == 0 {
                navigationController?.popViewController(animated: true)
            } else {
                let newContentOffset = CGPoint(x: view.frame.width * CGFloat(index - 1), y: currentContentOffset.y)
                scrollView.setContentOffset(newContentOffset, animated: true)
            }
        }
    }
}
