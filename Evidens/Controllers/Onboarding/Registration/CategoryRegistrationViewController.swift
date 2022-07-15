//
//  NameRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit

class CategoryRegistrationViewController: UIViewController {
    
    private var user: User
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let categoryLabel: UILabel = {
        let label = CustomLabel(placeholder: "Choose your main category")
        return label
    }()
    
    private let conditionsCategoryString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "Your category helps us verify you faster. At MyEvidens we verify our entire community. Who can join MyEvidens?")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "Your category helps us verify you faster. At MyEvidens we verify our entire community. Who can join MyEvidens?"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: grayColor, range: (aString.string as NSString).range(of: "Your category helps us verify you faster. At MyEvidens we verify our entire community. Who can join MyEvidens?"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        aString.addAttribute(NSAttributedString.Key.link, value: "presentCommunityInformation", range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        return aString
    }()
    
    lazy var instructionsCategoryLabel: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.attributedText = conditionsCategoryString
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.delegate = self
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "arrow.right")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private let professionalCategory = MECategoryView(title: "Professional")
    private let professorCategory = MECategoryView(title: "Professor")
    private let investigatorCategory = MECategoryView(title: "Research scientist")
    private let studentCategory = MECategoryView(title: "Student")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
        professionalCategory.delegate = self
        professorCategory.delegate = self
        investigatorCategory.delegate = self
        studentCategory.delegate = self
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Configure account"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle.fill"), style: .done, target: self, action: #selector(handleHelp))
        navigationItem.rightBarButtonItem?.tintColor = blackColor
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(categoryLabel, instructionsCategoryLabel, professionalCategory, investigatorCategory, professorCategory, studentCategory, nextButton)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            categoryLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            categoryLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            instructionsCategoryLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
            instructionsCategoryLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            instructionsCategoryLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            
            professionalCategory.topAnchor.constraint(equalTo: instructionsCategoryLabel.bottomAnchor, constant: 20),
            professionalCategory.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            professionalCategory.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8 / 2 - 5),
            professionalCategory.heightAnchor.constraint(equalToConstant: 120),
            
            investigatorCategory.topAnchor.constraint(equalTo: professionalCategory.topAnchor),
            investigatorCategory.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            investigatorCategory.leadingAnchor.constraint(equalTo: professionalCategory.trailingAnchor, constant: 10),
            investigatorCategory.heightAnchor.constraint(equalToConstant: 120),
            
            professorCategory.topAnchor.constraint(equalTo: professionalCategory.bottomAnchor, constant: 10),
            professorCategory.leadingAnchor.constraint(equalTo: professionalCategory.leadingAnchor),
            professorCategory.trailingAnchor.constraint(equalTo: professionalCategory.trailingAnchor),
            professorCategory.heightAnchor.constraint(equalToConstant: 120),
            
            studentCategory.topAnchor.constraint(equalTo: investigatorCategory.bottomAnchor, constant: 10),
            studentCategory.leadingAnchor.constraint(equalTo: investigatorCategory.leadingAnchor),
            studentCategory.trailingAnchor.constraint(equalTo: investigatorCategory.trailingAnchor),
            studentCategory.heightAnchor.constraint(equalToConstant: 120),
            
            nextButton.topAnchor.constraint(equalTo: studentCategory.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: studentCategory.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func handleNext() {
        let controller = ProfessionRegistrationViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleHelp() {
        
    }
}

extension CategoryRegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentCommunityInformation" {
            let controller = CommunityRegistrationViewController()
            let navController = UINavigationController(rootViewController: controller)
            
            if let presentationController = navController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
            present(navController, animated: true)
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}

extension CategoryRegistrationViewController: MECategoryViewDelegate {
    func didTapCategory(_ view: MECategoryView, completion: @escaping (Bool) -> Void) {
        professionalCategory.resetCategoryView()
        professorCategory.resetCategoryView()
        investigatorCategory.resetCategoryView()
        studentCategory.resetCategoryView()
        nextButton.isUserInteractionEnabled = true
        nextButton.configuration?.baseBackgroundColor = primaryColor
        
        switch view {
        case professionalCategory:
            user.category = .professional
        case professorCategory:
            user.category = .professor
        case investigatorCategory:
            user.category = .researcher
        case studentCategory:
            user.category = .student
        default:
            user.category = .none
        }
        completion(true)
    }
}

