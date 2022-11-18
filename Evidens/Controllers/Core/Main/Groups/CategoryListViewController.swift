//
//  CategoryListViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/11/22.
//

import UIKit


private let categoryCellReuseIdentifier = "CategoryCellReuseIdentifier"

protocol CategoryListViewControllerDelegate: AnyObject {
    func didTapAddCategories(categories: [Category])
}

class CategoryListViewController: UIViewController {
    
    weak var delegate: CategoryListViewControllerDelegate?
    
    private let searchBar = UISearchController()
    
    private var categories: [Category] = Category.allCategories()
    
    private var selectedCategories: [Category]

    enum Section { case main }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Category>!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    init(selectedCategories: [Category]) {
        self.selectedCategories = selectedCategories
        if self.selectedCategories.last?.name == "Add category" {
            self.selectedCategories.removeLast()
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        createDataSource()
        updateData(on: categories)
    }
    
    private func configureNavigationBar() {
        title = "Category"
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleCreateGroup))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        searchBar.searchBar.placeholder = "Category"
        navigationItem.hidesSearchBarWhenScrolling = false
        searchBar.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchBar
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.register(RegisterCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Category>(collectionView: collectionView, cellProvider: { collectionView, indexPath, category in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! RegisterCell
            cell.set(value: category.name)
            
            if self.selectedCategories.contains(category) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            
            return cell
        })
    }
    
    private func updateData(on category: [Category]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Category>()
        snapshot.appendSections([.main])
        snapshot.appendItems(category)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    @objc func handleCreateGroup() {
        delegate?.didTapAddCategories(categories: selectedCategories)
        navigationController?.popViewController(animated: true)
    }
}

extension CategoryListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let numberOfItemsSelected = collectionView.indexPathsForSelectedItems?.count as? Int else { return false }
        if numberOfItemsSelected < 3 { return true }
        // Show popup
        print("Show pop up")
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        selectedCategories.insert(Category(name: categories[indexPath.row].name), at: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let numberOfItemsSelected = collectionView.indexPathsForSelectedItems?.count as? Int else { return }
        let categoryIndex = selectedCategories.firstIndex { category in
            if category.name == categories[indexPath.row].name {
                return true
            }
            return false
        }
        
        if let categoryIndex = categoryIndex {
            selectedCategories.remove(at: categoryIndex)
            print(selectedCategories)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = numberOfItemsSelected > 0 ? true : false
    }
}
