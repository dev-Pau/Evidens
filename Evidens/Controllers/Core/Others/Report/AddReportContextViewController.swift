//
//  AddReportContextViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

protocol AddReportContextViewControllerDelegate: AnyObject {
    func didAddReport(_ report: Report)
}

class AddReportContextViewController: UIViewController {
    
    weak var delegate: AddReportContextViewControllerDelegate?
    private var report: Report
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contextTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reportContextTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add report details here..."
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = .label
        tv.tintColor = primaryColor
        tv.layer.borderWidth = 0.4
        tv.layer.borderColor = separatorColor?.cgColor
        tv.layer.cornerRadius = 5
        tv.keyboardDismissMode = .onDrag
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let textTracker = CharacterTextTracker(withMaxCharacters: 210)

    private let contextDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reportContextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString("Skip", attributes: container)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(report: Report) {
        self.report = report
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
         
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        view.addSubview(scrollView)

        if let reportInfo = report.reportInfo {
            reportContextTextView.placeholderLabel.text = reportInfo.isEmpty ? "" : "Add report details here..."
            reportContextTextView.text = reportInfo
            textTracker.updateTextTracking(toValue: reportInfo.count)
            textViewDidChange(reportContextTextView)
        }
        
        reportContextTextView.delegate = self
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        reportContextTextView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.25).isActive = true
        textTracker.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textTracker.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [reportContextTextView, textTracker])
        textStack.axis = .vertical
        //textStack.alignment = .trailing
        textStack.spacing = 0
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [contextTitle, textStack, contextDescription])
        stack.axis = .vertical
    
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, reportContextButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            
            reportContextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reportContextButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            reportContextButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            reportContextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        contextTitle.text = "Whenever you're prepared, would you like to include additional information?"
        contextDescription.text = "The report contains this information that could assist us in shaping our rules and policies. However, it's important to note that we cannot ensure that we'll act on the details presented here."
    }

    @objc func handleContinueReport() {
        let controller = ReportTargetViewController(report: report)
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleContinue() {
        guard !reportContextTextView.text.isEmpty else {
            report.reportInfo = nil
            delegate?.didAddReport(report)
            dismiss(animated: true)
            return
        }
        report.reportInfo = reportContextTextView.text
        delegate?.didAddReport(report)
        dismiss(animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}


extension AddReportContextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        reportContextButton.configuration?.baseBackgroundColor = count > 0 ? .label : .systemBackground
        reportContextTextView.placeholderLabel.text = count > 0 ? "" : "Add report details here..."
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        container.foregroundColor = count > 0 ? .systemBackground : .label
        reportContextButton.configuration?.attributedTitle = AttributedString(count > 0 ? "Add" : "Skip", attributes: container)
        textTracker.updateTextTracking(toValue: count)
        if count > 210 { reportContextTextView.deleteBackward() }
    }
}
