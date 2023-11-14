//
//  PagingSectionFooterView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/22.
//

import UIKit
import Combine

struct PagingInfo: Equatable, Hashable {
    let currentPage: Int
}

protocol PagingSectionFooterViewDelegate: AnyObject {
    func messageDidChange(_ index: Int)
}

class PagingSectionFooterView: UICollectionReusableView {
    weak var delegate: PagingSectionFooterViewDelegate?
    private var currentPage: Int = 0
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.isUserInteractionEnabled = false
        control.currentPageIndicatorTintColor = primaryColor
        control.pageIndicatorTintColor = .quaternarySystemFill
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
            if self.currentPage != pagingInfo.currentPage {
                self.currentPage = pagingInfo.currentPage
                self.delegate?.messageDidChange(pagingInfo.currentPage)
            }
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
