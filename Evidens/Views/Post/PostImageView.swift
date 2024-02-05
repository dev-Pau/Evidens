//
//  PostImageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/11/23.
//

import UIKit

protocol PostImagesDelegate: AnyObject {
    func zoomImage(_ image: [UIImageView], index: Int)
}

class PostImages: UIView {
    weak var zoomDelegate: PostImagesDelegate?

    var kind: PostImageKind? {
        didSet {
            images.forEach { $0.removeFromSuperview() }
            images.removeAll()
            configure()
        }
    }
    
    let ratio = 0.65
   
    private var images = [UIImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(kind: PostImageKind) {
        self.kind = kind
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        
        let padding: CGFloat = UIDevice.isPad ? 65 : 55
        
        let size = UIScreen.main.bounds.width - (padding + 10)

        guard let kind = kind else { return }
        
        switch kind {
            
        case .one:
            let image = PostImageView(frame: .zero)
            image.tapDelegate = self
            image.layer.cornerRadius = 12
            
            images.append(image)
            addSubview(image)
            NSLayoutConstraint.activate([
                image.topAnchor.constraint(equalTo: topAnchor),
                image.leadingAnchor.constraint(equalTo: leadingAnchor),
                image.trailingAnchor.constraint(equalTo: trailingAnchor),
                image.heightAnchor.constraint(equalToConstant: size * ratio),
                image.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

        case .two:
            for _ in 0 ..< 2 {
                let image = PostImageView(frame: .zero)
                image.tapDelegate = self
                image.layer.cornerRadius = 12
                images.append(image)
                addSubview(image)
            }
            
            NSLayoutConstraint.activate([
                images[0].topAnchor.constraint(equalTo: topAnchor),
                images[0].leadingAnchor.constraint(equalTo: leadingAnchor),
                images[0].heightAnchor.constraint(equalToConstant: size * ratio),
                images[0].trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4),
                images[0].bottomAnchor.constraint(equalTo: bottomAnchor),
                
                images[1].topAnchor.constraint(equalTo: topAnchor),
                images[1].leadingAnchor.constraint(equalTo: images[0].trailingAnchor, constant: 4),
                images[1].trailingAnchor.constraint(equalTo: trailingAnchor),
                images[1].bottomAnchor.constraint(equalTo: images[0].bottomAnchor),
            ])

            images[0].layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            images[1].layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        case .three:
            for _ in 0 ..< 3 {
                let image = PostImageView(frame: .zero)
                image.tapDelegate = self
                image.layer.cornerRadius = 12
                images.append(image)
                addSubview(image)
            }

            NSLayoutConstraint.activate([
                images[0].topAnchor.constraint(equalTo: topAnchor),
                images[0].leadingAnchor.constraint(equalTo: leadingAnchor),
                images[0].heightAnchor.constraint(equalToConstant: size * ratio),
                images[0].trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4),
                images[0].bottomAnchor.constraint(equalTo: bottomAnchor),
                
                images[1].topAnchor.constraint(equalTo: images[0].topAnchor),
                images[1].leadingAnchor.constraint(equalTo: images[0].trailingAnchor, constant: 4),
                images[1].trailingAnchor.constraint(equalTo: trailingAnchor),
                images[1].heightAnchor.constraint(equalToConstant: size * ratio / 2 - 4),

                images[2].topAnchor.constraint(equalTo: images[1].bottomAnchor, constant: 4),
                images[2].leadingAnchor.constraint(equalTo: images[0].trailingAnchor, constant: 4),
                images[2].trailingAnchor.constraint(equalTo: trailingAnchor),
                images[2].bottomAnchor.constraint(equalTo: images[0].bottomAnchor),
            ])
            
            images[0].layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            images[1].layer.maskedCorners = [.layerMaxXMinYCorner]
            images[2].layer.maskedCorners = [.layerMaxXMaxYCorner]
            
        case .four:
            for _ in 0 ..< 4 {
                let image = PostImageView(frame: .zero)
                image.tapDelegate = self
                image.layer.cornerRadius = 12
                images.append(image)
                addSubview(image)
            }
            
            NSLayoutConstraint.activate([
                images[0].topAnchor.constraint(equalTo: topAnchor),
                images[0].leadingAnchor.constraint(equalTo: leadingAnchor),
                images[0].heightAnchor.constraint(equalToConstant: size * ratio / 2 - 2),
                images[0].trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4),

                images[1].topAnchor.constraint(equalTo: images[0].topAnchor),
                images[1].leadingAnchor.constraint(equalTo: images[0].trailingAnchor, constant: 4),
                images[1].trailingAnchor.constraint(equalTo: trailingAnchor),
                images[1].bottomAnchor.constraint(equalTo: images[0].bottomAnchor),

                images[2].topAnchor.constraint(equalTo: images[0].bottomAnchor, constant: 4),
                images[2].leadingAnchor.constraint(equalTo: images[0].leadingAnchor),
                images[2].trailingAnchor.constraint(equalTo: images[0].trailingAnchor),
                images[2].heightAnchor.constraint(equalToConstant: size * ratio / 2 - 4),
                images[2].bottomAnchor.constraint(equalTo: bottomAnchor),
                
                images[3].topAnchor.constraint(equalTo: images[2].topAnchor),
                images[3].leadingAnchor.constraint(equalTo: images[1].leadingAnchor),
                images[3].trailingAnchor.constraint(equalTo: trailingAnchor),
                images[3].bottomAnchor.constraint(equalTo: images[2].bottomAnchor),
            ])
            
            images[0].layer.maskedCorners = [.layerMinXMinYCorner]
            images[1].layer.maskedCorners = [.layerMaxXMinYCorner]
            images[2].layer.maskedCorners = [.layerMinXMaxYCorner]
            images[3].layer.maskedCorners = [.layerMaxXMaxYCorner]
        }
        
        layer.borderColor = separatorColor.cgColor
        layer.borderWidth = 0.4
        layer.cornerRadius = 12
    }
    
    func add(images: [URL]) {
        guard let kind = kind else { return }
        switch kind {
            
        case .one:
            guard let firstImage = images.first else { return }
            self.images[0].sd_setImage(with: firstImage)
        case .two:
            guard images.count == 2 else { return }
            self.images[0].sd_setImage(with: images[0])
            self.images[1].sd_setImage(with: images[1])
        case .three:
            guard images.count == 3 else { return }
            self.images[0].sd_setImage(with: images[0])
            self.images[1].sd_setImage(with: images[1])
            self.images[2].sd_setImage(with: images[2])
        case .four:
            guard images.count == 4 else { return }
            self.images[0].sd_setImage(with: images[0])
            self.images[1].sd_setImage(with: images[1])
            self.images[2].sd_setImage(with: images[2])
            self.images[3].sd_setImage(with: images[3])
        }
    }
}

extension PostImages: PostImageViewDelegate {
    func didTapImage(_ image: UIImageView) {
        guard let kind = kind else { return }
        
        switch kind {
            
        case .one:
            zoomDelegate?.zoomImage(images, index: 0)
        case .two:
            if image == images[0] {
                zoomDelegate?.zoomImage(images, index: 0)
            } else {
                zoomDelegate?.zoomImage(images, index: 1)
            }
        case .three:
            if image == images[0] {
                zoomDelegate?.zoomImage(images, index: 0)
            } else if image == images[1] {
                zoomDelegate?.zoomImage(images, index: 1)
            } else {
                zoomDelegate?.zoomImage(images, index: 2)
            }
        case .four:
            if image == images[0] {
                zoomDelegate?.zoomImage(images, index: 0)
            } else if image == images[1] {
                zoomDelegate?.zoomImage(images, index: 1)
            } else if image == images[2] {
                zoomDelegate?.zoomImage(images, index: 2)
            } else {
                zoomDelegate?.zoomImage(images, index: 3)
            }
        }
    }
}


protocol PostImageViewDelegate: AnyObject {
    func didTapImage(_ image: UIImageView)
}

class PostImageView: UIImageView {
    
    weak var tapDelegate: PostImageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .quaternarySystemFill
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleImageTap() {
        tapDelegate?.didTapImage(self)
    }
}
