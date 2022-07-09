//
//  ClinicalTypeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

private let clinicalTypeCellReuseIdentifier = "ClinicalTypeCellReuseIdentifier"

class ClinicalTypeViewController: UIViewController {
    
    private var clinicalTypes = CaseType.allCaseTypes()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ClinicalTypeCell.self, forCellReuseIdentifier: clinicalTypeCellReuseIdentifier)
        tableView.allowsMultipleSelection = true
        tableView.allowsSelection = true
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureNavigationBar() {
        title = "Type details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        view.backgroundColor = .white
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    @objc func handleDone() {
        dismiss(animated: true)
    }
}

extension ClinicalTypeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: clinicalTypeCellReuseIdentifier, for: indexPath) as! ClinicalTypeCell
        cell.set(title: clinicalTypes[indexPath.row].type)
        print(clinicalTypes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clinicalTypes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}
