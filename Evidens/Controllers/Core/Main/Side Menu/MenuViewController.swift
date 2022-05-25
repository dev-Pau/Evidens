//
//  MenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/5/22.
//

import UIKit

class MenuViewController: UITableViewController {
    
    private lazy var image: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "x")
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSlideMenu))
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        view.addSubview(image)
        image.frame = CGRect(x: 50, y: 50, width: 40, height: 40)
    }

    @objc func closeSlideMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = "Menu"
        return cell
    }
     
}
