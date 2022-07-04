//
//  HomeImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/22.
//

import UIKit

protocol HomeImageViewControllerDelegate: AnyObject {
    func updateVisibleImageInScrollView(_ image: UIImageView)
}

class HomeImageViewController: UIViewController {
    
    weak var customDelegate: HomeImageViewControllerDelegate?
    
    private var postImage: [UIImage]!
    private var imageCount: Int!
    private var index: Int!

    private var zoomTransitioning = ZoomTransitioning()
    
    let pagePadding: CGFloat = 10
    var pageImages: [MEScrollImageView] = []
    
    var pagingScrollView: UIScrollView!
    
    var navigationBarIsHidden: Bool = false
    
    var singleTap: UITapGestureRecognizer!
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.isHidden = true
        return searchBar
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var postInfoView =  MEPostInfoView(comments: 1, commentText: "", shares: 1, shareText: "")
    
    private var postStatsView = MEPostStatsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        pagingScrollView.delegate = self
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(singleTap)
        navigationItem.titleView = searchBar
        navigationController?.delegate = zoomTransitioning
        
        if navigationController != nil, !(navigationController?.navigationBar.isHidden)! {
            navigationBarIsHidden = false
        }
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
        navigationController?.navigationBar.alpha = 0.7
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.alpha = 1
        pagingScrollView.backgroundColor = .clear
        containerView.removeFromSuperview()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapShare))
    }
    
    private func configure() {
        if let keyWindow = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
            keyWindow.addSubview(containerView)
            containerView.addSubview(whiteView)
          
            containerView.addSubview(postInfoView)
            containerView.addSubview(postStatsView)
 

            postInfoView.commentLabel.text = "3 comments"
            postInfoView.shareLabel.text = "6 shares"
            postInfoView.commentLabel.textColor = .black
            postInfoView.shareLabel.textColor = .black
            postStatsView.likesLabel.text = "1"
            
            NSLayoutConstraint.activate([
                containerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 100),
                
                whiteView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                whiteView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                whiteView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                whiteView.heightAnchor.constraint(equalToConstant: 200),

                postInfoView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -5),
                postInfoView.widthAnchor.constraint(equalToConstant: 200),
                postInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
                postInfoView.heightAnchor.constraint(equalToConstant: 50),
                
                postStatsView.centerYAnchor.constraint(equalTo: postInfoView.centerYAnchor),
                postStatsView.widthAnchor.constraint(equalToConstant: 150),
                postStatsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
                postStatsView.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
        
        
        let pagingScrollViewFrame = pagingScrollViewFrame()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.contentSize = contentSizeScrollView()
        pagingScrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(pagingScrollView)
        
        for index in 0..<imageCount {
            let page = MEScrollImageView()
            configure(page, for: index)
            pagingScrollView.addSubview(page)
            pageImages.append(page)
        }
        
        
        
        
    }
    
    func configure(_ page: MEScrollImageView, for index: Int) {
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
        let duration: TimeInterval = 0.2
        
        if navigationController != nil {
            
            if !navigationBarIsHidden {
                
                navigationBarIsHidden = true
                UIView.animate(withDuration: duration, animations: {
                    self.navigationController!.navigationBar.alpha = 0
                    self.containerView.alpha = 0
                    self.updateBackgroundColor()
                    
                }, completion: { (finished) in
                    self.navigationController!.navigationBar.isHidden = true
                })
            }
            else {
                
                self.navigationBarIsHidden = false
                
                UIView.animate(withDuration: duration) {
                    self.navigationController!.navigationBar.alpha = 1
                    self.containerView.alpha = 1
                    self.navigationController!.navigationBar.isHidden = false
                    self.updateBackgroundColor()
                }
            }
        }
    }
    
    @objc func didTapShare() {
        let activityVC = UIActivityViewController(activityItems: [self.postImage[0] as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func updateBackgroundColor() {
        if  !self.navigationBarIsHidden {
            self.updateBackground(to: .white)
        }
        else {
            self.updateBackground(to: .black)
        }
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
        //customDelegate?.updateVisibleImageInScrollView(pageImages[index].zoomImageView)
    }
}





