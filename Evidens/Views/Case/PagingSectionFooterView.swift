//
//  PagingSectionFooterView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/22.
//

import UIKit
import Combine

class PagingSectionFooterView: UICollectionReusableView {
    
    private lazy var pageControl: UIPageControl = {
            let control = UIPageControl()
            control.translatesAutoresizingMaskIntoConstraints = false
            control.isUserInteractionEnabled = false
            control.currentPageIndicatorTintColor = primaryColor
            control.pageIndicatorTintColor = grayColor
            return control
        }()
    
    private var pagingInfoToken: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    
    func subscribeTo(subject: PassthroughSubject<PagingInfo, Never>) {
        pagingInfoToken = subject.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] pagingInfo in
            guard let self = self else { return }
            self.pageControl.currentPage = pagingInfo.currentPage
        })
    }
     
    
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
