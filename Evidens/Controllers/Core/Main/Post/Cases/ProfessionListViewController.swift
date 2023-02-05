//
//  ProfessionListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/2/23.
//

import UIKit

let professionCellReuseIdentifier = "ProfessionCellReuseIdentifier"

protocol ProfessionListViewControllerDelegate: AnyObject {
    func didTapAddProfessions(profession: [Profession])
}

class ProfessionListViewController: UIViewController {
    
    weak var delegate: ProfessionListViewControllerDelegate?
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let professions = Profession.getAllProfessions()
    private var professionsSelected: [Profession]
    
    private let maxSelectedProfessions: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }
    
    init(professionsSelected: [Profession]) {
        self.professionsSelected = professionsSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Case professions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddProfessions))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    

    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: professionCellReuseIdentifier)
    }
    
    @objc func handleAddProfessions() {
        delegate?.didTapAddProfessions(profession: professionsSelected)
        navigationController?.popViewController(animated: true)
    }
}

extension ProfessionListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return professions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: professionCellReuseIdentifier, for: indexPath) as! RegisterCell
        cell.set(value: professions[indexPath.row].profession)
        if professionsSelected.contains(professions[indexPath.row]) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        professionsSelected.append(professions[indexPath.row])
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return professionsSelected.count < 4 ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let professionIndex = professionsSelected.firstIndex(where: { $0.profession == professions[indexPath.row].profession }) else { return }
        professionsSelected.remove(at: professionIndex)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return professionsSelected.count == 1 ? false : true

    }
}
