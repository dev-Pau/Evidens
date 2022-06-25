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
    
    private lazy var titleTextField: UITextField = {
        //NOT USE CUSTOM TEXT FIELD, USE A NEW CUSTOM TEXT VIEW
        let tf = CustomTextField(placeholder: "Insert a title for your document")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private let pagesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        configureDelegates()
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Add a Document"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddFile))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubviews(titleTextField, pdfView, pagesLabel)
        NSLayoutConstraint.activate([
            
            pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            pdfView.heightAnchor.constraint(equalToConstant: 400),
            
            titleTextField.bottomAnchor.constraint(equalTo: pdfView.topAnchor, constant: -10),
            titleTextField.centerXAnchor.constraint(equalTo: pdfView.centerXAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            
            pagesLabel.bottomAnchor.constraint(equalTo: pdfView.topAnchor, constant: -3),
            pagesLabel.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor)
        ])
        
        guard let document = PDFDocument(url: url) else { return }
        pdfView.document = document
        
        let pages = document.pageCount
        if pages == 1 {
            pagesLabel.text = "\(pages) page"
        } else {
            pagesLabel.text = "\(pages) pages"
        }
    }
    
    func configureDelegates() {
        //titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange() {
        guard let text = titleTextField.text else { return }
        navigationItem.rightBarButtonItem?.isEnabled = text.isEmpty ? false : true
    }
    
    @objc func handleAddFile() {
        print("Handle add file")
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
}

