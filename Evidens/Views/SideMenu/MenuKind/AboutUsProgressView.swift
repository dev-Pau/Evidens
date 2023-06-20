//
//  AboutUsProgressHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import UIKit

protocol AboutUsProgressViewDelegate: AnyObject {
    func timerDidFinish(for index: Int, upwards: Bool)
}

class AboutUsProgressView: UIView {
    
    private var progressView: UIProgressView!
    private var timer: Timer?
    private let totalDuration: TimeInterval = 3.8
    private let updateInterval: TimeInterval = 0.1
    weak var progressDelegate: AboutUsProgressViewDelegate?
    
    var progressViews: [UIProgressView] = []
    var currentProgressIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let numberOfSegments = 4
        let padding: CGFloat = 5
        
           let availableWidth = frame.width - CGFloat(numberOfSegments - 1) * padding
           let segmentWidth = availableWidth / CGFloat(numberOfSegments)
           
           for index in 0 ..< numberOfSegments {
               let progressView = UIProgressView(progressViewStyle: .default)
               progressView.tintColor = .white
               progressView.trackTintColor = separatorColor
               progressView.frame = CGRect(x: CGFloat(index) * (segmentWidth + padding), y: 0, width: segmentWidth, height: 10)
               addSubview(progressView)
               progressViews.append(progressView)
           }
        
        startTimer()
    }
    
    private func configure() {
        print(frame.width)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
    }
    
    private func startTimer() {
        timer?.invalidate()
        guard currentProgressIndex < 4, currentProgressIndex >= 0 else {
            return
            
        }
        // Create a new timer
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc private func updateProgress() {
        // Calculate the progress based on the elapsed time
        // Calculate the elapsed time
        let currentProgress = progressViews[currentProgressIndex].progress + Float(updateInterval / totalDuration)
        
        // Set the new progress value
        UIView.animate(withDuration: 0.2) {
            self.progressViews[self.currentProgressIndex].setProgress(currentProgress, animated: true)
        }
        //progressView.setProgress(currentProgress, animated: true)
        
        // Check if the progress is complete
        if currentProgress >= 1.0 {
            self.timer?.invalidate()
            progressDelegate?.timerDidFinish(for: self.currentProgressIndex, upwards: true)
            self.currentProgressIndex += 1
            startTimer()
            
            // Loading bar is complete, perform any desired actions
        }
    }
    
    func changeProgress(upwards: Bool) {
        timer?.invalidate()
        
        if upwards {
            self.progressViews[currentProgressIndex].setProgress(1, animated: false)
            progressDelegate?.timerDidFinish(for: self.currentProgressIndex, upwards: true)
            currentProgressIndex += 1
            startTimer()
        } else {
            self.progressViews[currentProgressIndex].setProgress(0, animated: false)
            progressDelegate?.timerDidFinish(for: self.currentProgressIndex, upwards: false)
            if currentProgressIndex > 0 {
                self.progressViews[currentProgressIndex - 1].setProgress(0, animated: false)
            }
            currentProgressIndex -= 1
            startTimer()
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
