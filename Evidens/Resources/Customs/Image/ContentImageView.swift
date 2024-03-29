//
//  ContentImageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/3/24.
//

import UIKit

protocol ContentImageViewDelegate: AnyObject {
    func isZoom(_ zoom: Bool)
}

class ContentImageView: UIScrollView {

    private var heightLayoutConstraint: NSLayoutConstraint!
    
    weak var zoomDelegate: ContentImageViewDelegate?
    private var size = CGSize()
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        minimumZoomScale = 0.1
        maximumZoomScale = 5.0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerImage()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(image: UIImage) {
        imageView.removeFromSuperview()
        imageView = UIImageView(image: image)
        addSubview(imageView)
        configureFor(image.size)
    }

    func configureFor(_ imageSize: CGSize) {
        contentSize = imageSize
        setMaxMinZoomScaleForCurrentBounds()
        zoomScale = minimumZoomScale
        
        imageView.addGestureRecognizer(self.zoomingTap)
        imageView.isUserInteractionEnabled = true
    }
    
    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale =  boundsSize.width  / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
    }
    
    func centerImage() {
        let boundsSize = bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        }
        else {
            frameToCenter.origin.x = 0
        }
    
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    func zoom(to point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return;
        }

        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        
        zoomDelegate?.isZoom(finalScale != minScale)
        
        let zoomRect = self.zoomRect(for: finalScale, withCenter: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
       
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
    
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(to: location, animated: true)
    }
    
    func resetZoom() {
        self.zoom(to: CGPoint(x: 0, y: 0), animated: true)
    }
}


extension ContentImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let zoomScale = scrollView.zoomScale
        guard zoomScale != scrollView.maximumZoomScale else { return }
        zoomDelegate?.isZoom(scrollView.isZooming)
    }
}
