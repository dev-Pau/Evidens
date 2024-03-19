//
//  ContentImageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/3/24.
//

import UIKit

protocol ContentImageViewControllerDelegate: AnyObject {
    
}

class ContentImageViewController: UIViewController {
    
    private var viewModel: ContentImageViewModel
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
        scrollView.backgroundColor = .clear
        view.backgroundColor = .black
    }

    init(image: UIImage, navVC: UINavigationController?) {
        self.viewModel = ContentImageViewModel(image: image, navVC: navVC)
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.navVC?.tabBarController?.tabBar.isHidden = true
        
        if let mainTabController = viewModel.navVC?.tabBarController as? MainTabController {
            mainTabController.disable()
        }
    }
    
    private func configure() {

        var frame = UIWindow.visibleScreenBounds
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
        let contentSize = CGSize(width: bounds.size.width, height: bounds.size.height)
        
        scrollView.contentSize = contentSize
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubviews(scrollView)
        
        let page = ContentImageView()
        page.zoomDelegate = self
        configure(page, for: 0)
        scrollView.addSubview(page)

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
                handleDismiss()
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
    
    func configure(_ page: ContentImageView, for index: Int) {
        page.frame = frameForPage(at: index)
        page.display(image: viewModel.image)
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.navVC?.tabBarController?.tabBar.isHidden = false
            
            strongSelf.view.backgroundColor = .black.withAlphaComponent(0)
            strongSelf.dismissButon.alpha = 0
            strongSelf.dotButton.alpha = 0
            
            if strongSelf.scrollView.frame.midY > strongSelf.view.frame.midY {
                strongSelf.scrollView.frame.origin.y = strongSelf.view.frame.height
            } else {
                strongSelf.scrollView.frame.origin.y = -strongSelf.view.frame.height
            }

            strongSelf.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if let mainTabController = strongSelf.viewModel.navVC?.tabBarController as? MainTabController, let viewControllers = strongSelf.viewModel.navVC?.viewControllers {
                
                if viewControllers.count == 1 {
                    if let currentController = viewControllers.last as? SearchViewController {
                        if !currentController.isPresentingSearchResults() {
                            mainTabController.enable()
                        }
                    } else {
                        mainTabController.enable()
                    }
                }
            }
            
            strongSelf.dismiss(animated: false)
        }
    }
    
    @objc func didTapThreeDots() {
        let activityVC = UIActivityViewController(activityItems: [viewModel.image as UIImage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        present(activityVC, animated: true, completion: nil)
    }
}

extension ContentImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
}

extension ContentImageViewController: ContentImageViewDelegate {
    func isZoom(_ zoom: Bool) {
        handleButtonsFrame(hidden: zoom)
        viewModel.isZoom = zoom
        scrollView.isScrollEnabled = !zoom
    }
}

extension ContentImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
