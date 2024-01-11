//
//  CaseImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/9/23.
//

import UIKit

protocol CaseImageViewControllerDelegate: AnyObject {
    func didAcceptImage(_ image: UIImage, for index: Int)
    func didRejectImage(_ image: UIImage, for index: Int)
}

class CaseImageViewController: UIViewController {
    
    weak var delegate: CaseImageViewControllerDelegate?
    
    private let image: UIImage
    private let index: Int
    
    let pagePadding: CGFloat = 10
    var pageImage: ScrollableImageView!
    
    var pagingScrollView: UIScrollView!

    var singleTap: UITapGestureRecognizer!
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .title3, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.accept, attributes: container)
        button.configuration?.baseBackgroundColor = primaryColor
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .title3, weight: .bold, scales: false)

        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.reject, attributes: container)
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = .white
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.baseForegroundColor = .white
        button.addTarget(self, action: #selector(handleReject), for: .touchUpInside)
        return button
    }()
    
    init(image: UIImage, index: Int) {
        self.image = image
        self.index = index
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = false
        pagingScrollView.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(singleTap)
        view.backgroundColor = .black
    }
    
    private func configure() {
        
        let pagingScrollViewFrame = pagingScrollViewFrame()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.contentSize = contentSizeScrollView()
        pagingScrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(pagingScrollView)
        
        let page = ScrollableImageView()
        configure(page, for: 0)
        pagingScrollView.addSubview(page)
        pageImage = page

        view.addSubviews(rejectButton, acceptButton)
        
        NSLayoutConstraint.activate([
            acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            acceptButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            
            rejectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            rejectButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            rejectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rejectButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func configure(_ page: ScrollableImageView, for index: Int) {
        page.frame = frameForPage(at: 0)
        page.display(image: image)
        singleTap.require(toFail: page.zoomingTap)
    }
    
    func frameForPage(at index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= 2*pagePadding
        pageFrame.origin.x = (bounds.size.width*CGFloat(index)) + pagePadding
        return pageFrame
    }
    
    func pagingScrollViewFrame() -> CGRect {
        var frame = UIScreen.main.bounds
        frame.origin.x -= pagePadding
        frame.size.width += 2*pagePadding
        return frame
    }
    
    func contentSizeScrollView() -> CGSize {
        let bounds = pagingScrollView.bounds
        return CGSize(width: bounds.size.width, height: bounds.size.height)
    }
   
    @objc func handleSingleTap() {
        
    }
    
    @objc func handleAccept() {
        delegate?.didAcceptImage(image, for: index)
        dismiss(animated: true)
    }
    
    @objc func handleReject() {
        delegate?.didRejectImage(image, for: index)
        dismiss(animated: true)
    }
}
