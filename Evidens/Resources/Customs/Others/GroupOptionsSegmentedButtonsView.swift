//
//  GroupOptionsSegmentedButtonsView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/12/22.
//

import UIKit

class GroupOptionsSegmentedButtonsView: UIView {
    
    weak var segmentedControlDelegate: SegmentedControlDelegate?
    
    // Title labels of the different buttons to switch
    private lazy var labels = [UILabel]()
    private var titles: [String]!
    
    // Bottom border to track labels
    private lazy var selectorView = UIView()
    
    public private(set) var selectedIndex: Int = 0
    public private(set) var pastIndex: Int = 0
    
    convenience init(frame: CGRect, titles: [String]) {
        self.init(frame:frame)
        self.titles = titles
    }
    
    /// Updates the view bottom border as we track x-value of the scrollView
    private func updateView() {
        // Remove & create labels again
        createLabels()
        // Create the selector view of the new tapped element
        configSelectedTap()
        // Add labels again
        configureUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    
    func setLabelsTitles(titles:[String]){
        self.titles = titles
        self.updateView()
    }
    
    /// Configures the selected view upon tapping a segment
    private func configSelectedTap() {
        // Get the number of segments to display
        let segmentsCount = CGFloat(titles.count)
        // Get the width of each selector dividing the screen with by the number of segments
        let selectorWidth = self.frame.width / segmentsCount
        // Add to view & configure the bottom border to track labels
        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height - 2, width: selectorWidth, height: 2))
        selectorView.backgroundColor = primaryColor
        addSubview(selectorView)
    }
    
    private func createLabels() {
        labels.removeAll()
        subviews.forEach ({$0.removeFromSuperview()})
        // Iterate all the titles
        for labelTitle in titles {
            // Create the label
            let label = UILabel()
            // Configure label tap
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wantsToChangeLabel(sender:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            label.addGestureRecognizer(tapGestureRecognizer)
            label.isUserInteractionEnabled = true
            
            // Configure label
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.textColor = grayColor
            label.textAlignment = .center
            label.text = labelTitle
            // Append new label to labels array
            labels.append(label)
        }
        labels[0].textColor = .black
    }
    
    /// Configure labels into a StackView to display them
    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    //MARK: - Actions
    
    /// Change the position of the bottom border as we select a new label. Furthermore, the collectionView is notified about the position to update contentView
    @objc func wantsToChangeLabel(sender: UITapGestureRecognizer) {
        for (index, label) in labels.enumerated() {
            // Check what label is selected
            if label == sender.view {
                // Get the starting point of the new label selected
                let _ = frame.width / CGFloat(titles.count) * CGFloat(index)
                // Update the new selected index of the CustomSegmentedButtonsView
                selectedIndex = index
                
                // Notify the controller about a change
                
                segmentedControlDelegate?.indexDidChange(from: pastIndex, to: selectedIndex)
                
                // Animate transition from one label to other
                //UIView.animate(withDuration: 0.0) {
                //self.selectorView.frame.origin.x = selectorPosition
                //}
            }
        }
        pastIndex = selectedIndex
    }
}

extension GroupOptionsSegmentedButtonsView: CollectionViewDidScrollDelegate {
    func collectionViewDidScroll(for x: CGFloat) {
        let minUnit = (self.frame.width / 2) * 1/2
        
        UIView.animate(withDuration: 0.0) { [self] in
            // Update starting point. Goes from 0 to UIScreen.main.bounds.width going through all the different labels
            self.selectorView.frame.origin.x = x
            for (_, view) in subviews.enumerated() {
                if view is UIStackView {
                    guard let stack = view as? UIStackView else { return }
                    for _ in stack.arrangedSubviews.enumerated() {
                        
                        // Get all the labels from the stackView
                        guard let firstLabel = stack.subviews[0] as? UILabel else { return }
                        guard let secondLabel = stack.subviews[1] as? UILabel else { return }
                        
                        // Depending on distance of the origin.x it changes the colors accordingly
                        switch self.selectorView.frame.origin.x {
                        case 0..<(minUnit):
                            firstLabel.textColor = .black
                            secondLabel.textColor = grayColor
                            pastIndex = 0

                        case (minUnit)...self.frame.width:
                            firstLabel.textColor = grayColor
                            secondLabel.textColor = .black
                            pastIndex = 1
                            
                        default:
                            print("No proper label to display")
                        }
                    }
                }
            }
        }
    }
}
