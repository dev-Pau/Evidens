//
//  AppStrings.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/5/23.
//

import Foundation

/// A structure containing static strings used throughout the app.
struct AppStrings {
    
    struct Appearance {
        static let dark = "Dark Mode"
        static let system = "Use Device Settings"
        static let light = "Light Mode"
    }
    
    struct Global {
        static let done = "Done"
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let add = "Add"
    }
    
    struct Characters {
        static let dot = " • "
    }
    
    struct Icons {
        static let pin = "pin"
        static let fillPin = "pin.fill"
        static let trash = "trash"
        static let copy = "doc"
        static let share = "square.and.arrow.up"
        static let plus = "plus"
        static let leftChevron = "chevron.left"
        static let exclamation = "exclamationmark"
        static let clockwiseArrow = "arrow.clockwise"
        static let note = "note"
        static let moon = "moon.stars"
        static let sun = "sun.max"
        static let gear = "gearshape"
    }
    
    struct Actions {
        static let pin = "Pin"
        static let unpin = "Unpin"
        static let copy = "Copy"
        static let share = "Share"
    }
    
    struct Title {
        static let conversation = "Conversations"
        static let message = "Messages"
        static let newMessage = "New Message"
        static let user = "Add User"
    }
    
    struct Placeholder {
        static let message = "Text Message"
    }
    
    struct Assets {
        static let profile = "user.profile"
        static let emptyMessage = "message.empty"
        static let paperplane = "paperplane"
    }
    
    struct Evidence {
        static let evidence = "Evidence Based"
    }
    
    struct Alerts {
        
        struct Title {
            static let deleteConversation = "Delete Conversation"
            static let deleteMessage = "Delete Message"
            static let resendMessage = "Resend This Message"
            static let clearRecents = "Clear Recent Searches"
        }
        
        struct Subtitle {
            static let deleteAlert = "This conversation will be deleted from your inbox. Other pople in the conversation will still be able to see it."
            static let clearRecents = "Are you sure you want to clear your most recent searches?"
        }
    }
    
    struct Menu {
        static let deleteMessage = "Delete Message"
        static let resendMessage = "Try Sending Again"
        static let sharePhoto = "Share Photo"
        static let copy = "Copy"
    }
    
    struct Reference {
        static let linkTitle = "Link Reference"
        static let linkContent = "The content you are viewing is backed up by a web link that provides evidence supporting the ideas and concepts presented."
        static let citationTitle = "Complete Citation"
        static let citationContent = "The content you are viewing is supported by a reference that provides evidence supporting the ideas and concepts presented."
    }
    
    struct Display {
        static let groupPrivacyTitle = "Privacy Rules"
        static let groupPrivacyContent = "When content is shared only with group members, it means that the information is restricted to a specific group of individuals who have been granted access to it. This practice helps to maintain the privacy and security of the information being shared. Only those who have been given permission to join the group can view and interact with the content, which creates a trusted and controlled environment. This approach ensures that the information remains within the intended audience and is not accessible to the general public or anyone who is not a member of the group."
        static let jobPrivacyTitle = "Privacy Rules"
        static let jobPrivacyContent = "To ensure the security and privacy of our users, we want to remind you that you are about to provide your personal contact information, including your full name, email address, phone number, and resume. Please note that this information will be shared with the hiring personnel of the company or organization you are applying to. They will use your contact information to communicate with you regarding your application and potential employment opportunities."
        static let joinTitle = "Eligibility Requirements"
        static let joinContent = "Our healthcare professional and student application is designed to connect individuals who are interested in healthcare-related topics. To ensure that the application is used by the intended audience, we have identified three categories of users who are eligible to join\n\n• Healthcare Professionals (e.g. physicians, nurses, dentists, pharmacists, allied health professionals)\n• Healthcare Students (e.g. medical students, nursing students, dental students, allied health students)\n• Retired Healthcare Professionals."
    }
    
    struct Report {
        
        struct Target {
            static let myselfTitle = "Myself"
            static let myselfContent = "The individual is either creating content that is directed towards themselves or consuming content that is personalized or tailored to their preferences."
            static let myselfSummary = "This report is for me."
            static let groupTitle = "Someone else or a specific group of people"
            static let groupContent = "This content is directed at or mentions someone else or a specific group of people —— like racial or religious groups."
            static let groupSummary = "This report is for someone else or a specific group of people."
            static let everyoneTitle = "Everyone"
            static let everyoneContent = "This content is isn't targeting a specific person or group, but it affects everyone —— like misleading information or sensitive content."
            static let everyoneSummary = "This report is for everyone."
        }
        
        struct Topics {
            static let identityTitle = "Attacked because of the identity"
            static let identityContent = "Slurs, misgendering, racist or sexist stereotypes, encouraging others to harass, sending hateful imagery or could risk identifying the patient."
            static let harassTitle = "Harassed or intimidated with violence"
            static let harrassContent = "Sexual narassment, group narassment, insults or name calling, posting private info, threatening to expose private into, violent event denial, violent threats, celebration of violent acts."
            static let spamTitle = "Spammed"
            static let spamContent = "Posting malicious links, fake engagement, repetitive replies, or Direct Messages."
            static let sensibleTitle = "Shown sensitive or disturbing content"
            static let sensibleContent = "Posting graphic or violent content related to self-harm, suicide, or other sensitive topics, that could be triggering or harmful to some users."
            static let evidenceTitle = "Lacking medical evidence or shown misleading information"
            static let evidenceContent = "This content contains a claim that isn't supported by data."
            static let tipsTitle = "Offered tips or currency - or encouraged to send them —— in a way that's deceptive or promotes or causes harm"
            static let tipsContent = "Behaviors that offer tips and incentives, encourage users to engage in deceptive practices, promote inappropriate content or behavior, or exploit the platform to earn rewards or other currencies."
        }
    }
    
    struct Search {
    
        struct Topics {
            static let people = "People"
            static let posts = "Posts"
            static let cases = "Posts"
            static let groups = "Posts"
            static let jobs = "Jobs"
        }
        
        struct Bar {
            static let message = "Search Direct Messages"
        }
    }
}