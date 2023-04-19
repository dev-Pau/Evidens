//
//  ReviewDocumentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/2/23.
//

import UIKit
import PDFKit

class ReviewDocumentViewController: UIViewController {
    private var url: URL
    
    private let pdfView: PDFView = {
        let pdf = PDFView()
        pdf.displayDirection = .vertical
        pdf.autoScales = true
        pdf.translatesAutoresizingMaskIntoConstraints = false
        return pdf
    }()

    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.8)
        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.configuration?.buttonSize = .mini
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
        dismissButton.frame = CGRect(x: 20, y: 60, width: 30, height: 30)
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        view.addSubviews(pdfView, dismissButton)
        guard let document = PDFDocument(url: url) else {
            return }
        pdfView.document = document
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
