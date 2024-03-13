//
//  ZoomImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/22.
//

import UIKit

class ZoomImageViewController: UIViewController {
    
    private var viewModel: HomeImageViewModel
    private var zoomTransitioning = ZoomTransitioning()
    private var topButtonConstraint: NSLayoutConstraint!
    
    
    private var scrollView: UIScrollView!
    
    var singleTap: UITapGestureRecognizer!
    
    private let padding: CGFloat = 10

    private lazy var dismissButon: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        let size: CGFloat = UIDevice.isPad ? 23 : 18
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .clear

        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private lazy var dotButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        let size: CGFloat = UIDevice.isPad ? 25 : 20
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .clear

        button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        return button
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(singleTap)
        view.backgroundColor = .black
        navigationController?.delegate = zoomTransitioning
    }
    
    init(images: [UIImage], index: Int) {
        self.viewModel = HomeImageViewModel(images: images, index: index)
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var offset = 0.0
        
        let index = viewModel.index
        
        switch index {
        case 0:
            offset = 0.0
        case 1:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 1) * padding
        case 2:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 2) * padding
        case 3:
            offset = CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 3) * padding
        default:
            break
        }
        
        scrollView.contentOffset = CGPoint(x: offset, y: 0)
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
        scrollView.backgroundColor = .clear
    }
    
    private func configure() {
        var frame = UIScreen.main.bounds
        frame.origin.x -= padding
        frame.size.width += 2 * padding

        scrollView = UIScrollView(frame: frame)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)

        let bounds = scrollView.bounds
        let contentSize = CGSize(width: bounds.size.width * CGFloat(viewModel.images.count), height: bounds.size.height)
        
        scrollView.contentSize = contentSize
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(scrollView)
        
        for index in 0 ..< viewModel.images.count {
            let page = ZoomImageView()
            page.zoomDelegate = self
            configure(page, for: index)
            scrollView.addSubview(page)
            viewModel.pageImages.append(page)
        }
        
        view.addSubviews(dismissButon, dotButton)
        
        let padding: CGFloat = UIDevice.isPad ? 55 : 45
        let size: CGFloat = UIDevice.isPad ? 38 : 33
        
        topButtonConstraint = dismissButon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            topButtonConstraint,
            dismissButon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding / 2),
            dismissButon.heightAnchor.constraint(equalToConstant: size),
            dismissButon.widthAnchor.constraint(equalToConstant: size),
            
            dotButton.topAnchor.constraint(equalTo: dismissButon.topAnchor),
            dotButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding / 2)),
            dotButton.heightAnchor.constraint(equalToConstant: size),
            dotButton.widthAnchor.constraint(equalToConstant: size)
        ])
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !viewModel.isZoom else { return }
        
        let translation = gesture.translation(in: scrollView)
        let velocity = gesture.velocity(in: scrollView)
        
        switch gesture.state {
        case .changed:
            let index = viewModel.index
            
            var canSwipeVertical: Bool = false
            
            switch index {
            case 0:
                canSwipeVertical = scrollView.contentOffset.x == 0.0
            case 1:
                canSwipeVertical = scrollView.contentOffset.x == CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 1) * padding
            case 2:
                canSwipeVertical = scrollView.contentOffset.x == CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 2) * padding
            case 3:
                canSwipeVertical = scrollView.contentOffset.x == CGFloat(index) * UIScreen.main.bounds.width + CGFloat(index + 3) * padding
            default:
                canSwipeVertical = false
            }

            guard canSwipeVertical else {
                viewModel.isScrollingHorizontal = true
                return
            }

            if abs(translation.y) > 1.2 * abs(translation.x) && !viewModel.isScrollingHorizontal {
                scrollView.isScrollEnabled = false
                handleButtonsFrame(hidden: true)
                scrollView.frame.origin.y = translation.y
            }
        case .ended:
            guard !viewModel.isScrollingHorizontal else {
                viewModel.isScrollingHorizontal = false
                return
            }

            viewModel.isScrollingHorizontal = false
            scrollView.isScrollEnabled = true
            
            if abs(velocity.y) > 1500 {
                navigationController?.popViewController(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.scrollView.frame.origin.y = strongSelf.scrollView.contentOffset.y
                    strongSelf.view.layoutIfNeeded()
                } completion: { [weak self] completed in
                    guard let strongSelf = self else { return }
                    strongSelf.handleButtonsFrame(hidden: false)
                }
            }

        default:
            break
        }
    }
    
    func configure(_ page: ZoomImageView, for index: Int) {
        page.frame = frameForPage(at: index)
        page.display(image: viewModel.images[index])
        singleTap.require(toFail: page.zoomingTap)
    }
    
    func frameForPage(at index: Int) -> CGRect {
        let bounds = scrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= 2*padding
        pageFrame.origin.x = (bounds.size.width*CGFloat(index)) + padding
        return pageFrame
    }

    @objc func handleSingleTap() {
        if viewModel.buttonsHidden {
            handleButtonsFrame(hidden: false)
        } else {
            handleButtonsFrame(hidden: true)
        }
    }
    
    private func handleButtonsFrame(hidden: Bool) {
        guard hidden != viewModel.buttonsHidden, !viewModel.buttonsAnimating else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.buttonsAnimating = true
            let constant = strongSelf.topButtonConstraint.constant
            
            strongSelf.topButtonConstraint.constant = hidden ? constant - 2 * strongSelf.padding : constant + 2 * strongSelf.padding
            strongSelf.dismissButon.alpha = hidden ? 0 : 1
            strongSelf.dotButton.alpha = hidden ? 0 : 1
            strongSelf.viewModel.buttonsHidden = hidden
            strongSelf.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.buttonsAnimating = false
        }
    }
    
    @objc func handleDismiss() {
        dismissButon.alpha = 0
        dotButton.alpha = 0
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapThreeDots() {
        let activityVC = UIActivityViewController(activityItems: [viewModel.images[viewModel.index] as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        present(activityVC, animated: true, completion: nil)
    }
    
    func updateBackgroundColor() {
        view.backgroundColor = .systemBackground
    }

    func updateBackground(to color: UIColor) {
        view.backgroundColor = color
        scrollView?.backgroundColor = color
    }
}


extension ZoomImageViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.pageImages[viewModel.index].zoomImageView
    }
}

extension ZoomImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        switch scrollView.contentOffset.x {
        case 0.0 ..< UIScreen.main.bounds.width + 2 * padding:
            viewModel.index = 0
        case UIScreen.main.bounds.width + 2 * padding ..< 2 * UIScreen.main.bounds.width + 3 * padding:
            viewModel.index = 1
        case 2 * UIScreen.main.bounds.width + 3 * padding ..< 3 * UIScreen.main.bounds.width + 4 * padding:
            viewModel.index = 2
        case 3 * UIScreen.main.bounds.width + 4 * padding ..< 4 * UIScreen.main.bounds.width + 5 * padding:
            viewModel.index = 3
        default:
            break
        }
    }
}

extension ZoomImageViewController: ZoomImageViewDelegate {
    func isZoom(_ zoom: Bool) {
        handleButtonsFrame(hidden: zoom)
        viewModel.isZoom = zoom
        scrollView.isScrollEnabled = !zoom
    }
}


extension ZoomImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}





