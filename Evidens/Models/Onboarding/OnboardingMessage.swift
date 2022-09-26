//
//  OnboardingMessage.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/9/22.
//

import UIKit

struct OnboardingMessage {
    let title: String
    let description: String
}

extension OnboardingMessage {
    
    static func getAllOnboardingMessages() -> [OnboardingMessage] {
        var messages: [OnboardingMessage] = []
        let firstMessage = OnboardingMessage(title: "Share clinical cases", description: "Choose how you want to share them and start to receive feedback from the community.")
        messages.append(firstMessage)
        
        let secondMessage = OnboardingMessage(title: "Expand your network", description: "Find professional from multiple disciplines and connect with them.")
        messages.append(secondMessage)
        
        let thirdMessage = OnboardingMessage(title: "Stay up-to-date", description: "See what others are talking about and interact with it")
        messages.append(thirdMessage)
        
        let fourthMessage = OnboardingMessage(title: "Get rewarded", description: "Your contributions improve the healthcare community and that is why you will be rewarded.")
        messages.append(fourthMessage)

        return messages
    }
}


