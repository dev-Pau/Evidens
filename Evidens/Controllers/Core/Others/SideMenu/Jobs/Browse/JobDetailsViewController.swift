//
//  JobDetailsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

class JobDetailsViewController: UIViewController {
    
    private var job: Job
    private var company: Company
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemRed
    }
    
    init(job: Job, company: Company) {
        self.job = job
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
