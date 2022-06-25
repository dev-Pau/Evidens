//
//  FileConfiguratorViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/6/22.
//

import UIKit
import PDFKit

class FileConfiguratorViewController: UIViewController {
    
    private var url: URL
    
    private let pdfView: PDFView = {
        let pdf = PDFView()
        pdf.displayDirection = .horizontal
        pdf.autoScales = true
        pdf.translatesAutoresizingMaskIntoConstraints = false
        return pdf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
        guard let document = PDFDocument(url: url) else { return }
        pdfView.document = document
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddFile))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor.withAlphaComponent(0.5)
    }
    
    private func configureUI() {
        title = "Add a File"
        
        view.backgroundColor = .white
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            pdfView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    @objc func handleAddFile() {
        //Handle add file
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
}
