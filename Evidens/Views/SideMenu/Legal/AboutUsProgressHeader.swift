//
//  AboutUsProgressHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import UIKit

class AboutUsProgressHeader: UICollectionReusableView {
    
    private var progressView: UIProgressView!
    private var timer: Timer?
    private let totalDuration: TimeInterval = 5.0 // Total duration for the loading bar
    private let updateInterval: TimeInterval = 0.1 // Interval to update the progress
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemTeal
        addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 10)
        ])

        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        // Create a new timer
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc private func updateProgress() {
        // Calculate the progress based on the elapsed time
        // Calculate the elapsed time
        let currentProgress = progressView.progress + Float(updateInterval / totalDuration)
            
            // Set the new progress value
        UIView.animate(withDuration: 0.2) {
            self.progressView.setProgress(currentProgress, animated: true)
        }
            //progressView.setProgress(currentProgress, animated: true)
            
            // Check if the progress is complete
            if currentProgress >= 1.0 {
                timer?.invalidate()
                // Loading bar is complete, perform any desired actions
            }
    }
    
    /*
     private func startTimer() {
         // Invalidate any existing timer
         timer?.invalidate()
         
         // Create a new timer
         timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
     }

     @objc private func updateProgress() {
         // Calculate the progress based on the elapsed time
         let elapsedTime = updateInterval * Double(progressView.progress)
         let progress = Float(elapsedTime / totalDuration)
         
         // Update the progress view
         progressView.setProgress(progress, animated: true)
         
         // Check if the progress is complete
         if progress >= 1.0 {
             timer?.invalidate()
             // Loading bar is complete, perform any desired actions
         }
     }
     */
    
    
    /*
     var progressViews: [UIProgressView] = []

     for index in 0..<segmentCount {
         let progressView = UIProgressView(progressViewStyle: .default)
         progressView.frame = CGRect(x: CGFloat(index) * segmentWidth, y: 0, width: segmentWidth, height: 20)
         progressView.progress = Float((index + 1) * 25) / 100.0
         containerView.addSubview(progressView)
         
         progressViews.append(progressView)  // Add progress view to the array
     }
     */
}
