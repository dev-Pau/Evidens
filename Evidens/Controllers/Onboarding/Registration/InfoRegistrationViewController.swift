//
//  UserInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/1/22.
//

import UIKit
import JGProgressHUD

private let reuseIdentifier = "UserTypeCell"

class InfoRegistrationViewController: UIViewController {
    
    //MARK: - Properties
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var credentials: AuthCredentials
    
    var dataSource = ["Healthcare professional", "Research scientist", "Teacher", "Student"]
    
    public var firstName: String = ""
    
    private var category = 5

    private let welcomeText: UILabel = {
        let label = CustomLabel(placeholder: "")
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size: 13)
        label.textColor = .black
        label.text = "Please fill out the form below so we can complete your profile and give you a better experience using Evidens."
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let userTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Category", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 18)
        button.addTarget(self, action: #selector(userTypeButtonPressed), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    private lazy var transparentView: UIView = {
        let window = UIView()
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        window.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        window.addGestureRecognizer(tap)
        return window
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightGray
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = .white
        button.setDimensions(height: 40, width: 40)
        button.layer.cornerRadius = 40 / 2
        button.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let tableView = UITableView()
    
    let scrollView = UIScrollView()

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RegisterTypeCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    init(credentials: AuthCredentials) {
        self.credentials = credentials
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .white
        
        welcomeText.text = "Hi \(firstName), we want to know more about you."
        
        let stack = UIStackView(arrangedSubviews: [welcomeText, instructionsLabel])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.setWidth(UIScreen.main.bounds.width * 0.8)
        
        view.addSubview(userTypeButton)
        userTypeButton.centerX(inView: view)
        userTypeButton.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 20)
        
        view.addSubview(transparentView)
        transparentView.alpha = 0
        
        view.addSubview(nextButton)
        nextButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: userTypeButton.rightAnchor)
    }
    
    func addTransparentView(frame: CGRect) {
        tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.height, width: frame.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        tableView.reloadData()
        
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.height + 5, width: frame.width, height: CGFloat(self.dataSource.count * 40))
        }, completion: nil)
    }
                       
    //MARK: - Actions
    
    @objc func userTypeButtonPressed() {
        addTransparentView(frame: userTypeButton.frame)
    }
    
    @objc func removeTransparentView() {
        let frame = userTypeButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.height, width: frame.width, height: 0)
        }, completion: nil)
    }
    
    @objc func continueButtonPressed() {
        //Registrates user to Firebase
        spinner.show(in: view)
        
        AuthService.registerUser(withCredential: credentials) { error in
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }

            if let error = error {
                print("DEBUG: Failed to register user \(error.localizedDescription)")
                return
            }
            
            //Succesfully registrates user and present a "Welcome Screen" with email instructions
            //After user registrates, signOut to avoid retention cycle
            AuthService.logout()
            let controller = EmailRegistrationViewController()
            controller.firstName = self.firstName
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension InfoRegistrationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RegisterTypeCell
        cell.userTypeTextLabel.text = dataSource[indexPath.row]
        //cell.notificationTypeImageView.image = UIImage(systemName: imageTypeDataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        category = indexPath.row
        userTypeButton.setTitle(dataSource[indexPath.row], for: .normal)
        userTypeButton.backgroundColor = UIColor(rgb: 0x79CBBF)
        credentials.category = dataSource[indexPath.row]
        nextButton.backgroundColor = UIColor(rgb: 0x79CBBF)
        nextButton.isEnabled = true
        nextButton.isHidden = false
        removeTransparentView()
    }
}

