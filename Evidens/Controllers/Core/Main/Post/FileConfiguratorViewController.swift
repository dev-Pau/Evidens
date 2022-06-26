//
//  FileConfiguratorViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/6/22.
//

import UIKit
import PDFKit

protocol FileConfiguratorViewControllerDelegate: AnyObject {
    func addDocumentToPost(title: String, numberOfPages: Int, documentImage: UIImage, documentURL: URL)
}

class FileConfiguratorViewController: UIViewController {
    
    private var url: URL
    
    private var numberOfPages: Int = 0
    
    weak var delegate: FileConfiguratorViewControllerDelegate?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let tf = METextField(placeholder: "Insert a title for your document")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private let pagesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
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
    
    private var postImage = UIImage()
    
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
        view.addSubviews(titleLabel ,titleTextField, pdfView, pagesLabel)
        NSLayoutConstraint.activate([
            
            pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            pdfView.heightAnchor.constraint(equalToConstant: 400),
            
            titleTextField.bottomAnchor.constraint(equalTo: pdfView.topAnchor, constant: -20),
            titleTextField.centerXAnchor.constraint(equalTo: pdfView.centerXAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            
            pagesLabel.bottomAnchor.constraint(equalTo: pdfView.topAnchor, constant: -3),
            pagesLabel.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        guard let document = PDFDocument(url: url) else { return }
        pdfView.document = document
        
        numberOfPages = document.pageCount
        
        if numberOfPages == 1 {
            pagesLabel.text = "\(numberOfPages) page"
        } else {
            pagesLabel.text = "\(numberOfPages) pages"
        }
        
        guard let page = document.page(at: 0) else { return }
        
        postImage = getImageFromPDF(atPage: page)
    }
    
    func configureDelegates() {
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange() {
        guard let text = titleTextField.text else { return }
        navigationItem.rightBarButtonItem?.isEnabled = text.isEmpty ? false : true
    }
    
    @objc func handleAddFile() {
        delegate?.addDocumentToPost(title: titleTextField.text!, numberOfPages: numberOfPages, documentImage: postImage, documentURL: url)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }

}

extension FileConfiguratorViewController {
    func getImageFromPDF(atPage page: PDFPage) -> UIImage {
        let pageRect = page.bounds(for: .mediaBox)
        
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))
            ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        return img
    }
}

