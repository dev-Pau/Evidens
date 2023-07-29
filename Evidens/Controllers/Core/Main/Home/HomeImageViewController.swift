//
//  HomeImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/22.
//

import UIKit

class HomeImageViewController: UIViewController {
    
    private var postImage: [UIImage]!
    private var imageCount: Int!
    private var index: Int!
    
    
    private var zoomTransitioning = ZoomTransitioning()
    
    let pagePadding: CGFloat = 10
    var pageImages: [ScrollableImageView] = []
    
    var pagingScrollView: UIScrollView!
    
    var statusBarIsHidden: Bool = false
    
    var singleTap: UITapGestureRecognizer!
    
    private lazy var dismissButon: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private lazy var threeDotsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.baseForegroundColor = .red
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        return button
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.isHidden = true
        return searchBar
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagingScrollView.delegate = self
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        navigationItem.titleView = searchBar
        view.addGestureRecognizer(singleTap)
        view.backgroundColor = .black
        navigationController?.delegate = zoomTransitioning
    }
    
    init(image: [UIImage], imageCount: Int, index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.postImage = image
        self.imageCount = imageCount
        self.index = index
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var offset = 0.0
        
        switch index {
        case 0:
            offset = 0.0
        case 1:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 1) * pagePadding
        case 2:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 2) * pagePadding
        case 3:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 3) * pagePadding
        default:
            break
        }
        
        pagingScrollView.contentOffset = CGPoint(x: offset, y: 0)
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
    
    private func configure() {
        
        let pagingScrollViewFrame = pagingScrollViewFrame()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.contentSize = contentSizeScrollView()
        pagingScrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(pagingScrollView)
        
        for index in 0 ..< imageCount {
            let page = ScrollableImageView()
            configure(page, for: index)
            pagingScrollView.addSubview(page)
            pageImages.append(page)
        }
        
        view.addSubviews(dismissButon, threeDotsButton)
        
        NSLayoutConstraint.activate([
            dismissButon.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            dismissButon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dismissButon.heightAnchor.constraint(equalToConstant: 33),
            dismissButon.widthAnchor.constraint(equalToConstant: 33),
            
            threeDotsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            threeDotsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            threeDotsButton.heightAnchor.constraint(equalToConstant: 33),
            threeDotsButton.widthAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    func configure(_ page: ScrollableImageView, for index: Int) {
        page.frame = frameForPage(at: index)
        page.display(image: postImage[index])
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
        return CGSize(width: bounds.size.width*CGFloat(imageCount), height: bounds.size.height)
    }
    
    @objc func handleSingleTap() {
        statusBarIsHidden.toggle()
        if statusBarIsHidden {
            UIView.animate(withDuration: 0.2) {
                self.dismissButon.alpha = 0
                self.threeDotsButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.dismissButon.alpha = 1
                self.threeDotsButton.alpha = 1
            }
        }
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapThreeDots() {
        let activityVC = UIActivityViewController(activityItems: [self.postImage[index] as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func updateBackgroundColor() {
        view.backgroundColor = .systemBackground
    }

    func updateBackground(to color: UIColor) {
        self.view.backgroundColor = color
        pagingScrollView?.backgroundColor = color
    }
}


extension HomeImageViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return pageImages[index].zoomImageView
    }
}

extension HomeImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch pagingScrollView.contentOffset.x {
        case 0.0..<(UIScreen.main.bounds.width + 2*pagePadding):
            index = 0
        case UIScreen.main.bounds.width + 2*pagePadding..<2*UIScreen.main.bounds.width + 3*pagePadding:
            index = 1
        case 2*UIScreen.main.bounds.width + 3*pagePadding..<3*UIScreen.main.bounds.width + 4*pagePadding:
            index = 2
        case 3*UIScreen.main.bounds.width + 4*pagePadding..<4*UIScreen.main.bounds.width + 5*pagePadding:
            index = 3
        default:
            break
        }
    }
}





