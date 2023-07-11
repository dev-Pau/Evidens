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
        static let go = "Continue"
        static let skip = "Skip for now"
        static let help = "Help"
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
        static let rightChevron = "chevron.right"
        static let exclamation = "exclamationmark"
        static let clockwiseArrow = "arrow.clockwise"
        static let backArrow = "arrow.backward"
        static let note = "note"
        static let rightArrow = "arrow.right"
        static let moon = "moon.stars"
        static let sun = "sun.max"
        static let gear = "gearshape"
        static let paperplane = "paperplane"
        static let apple = "applelogo"
        static let fillPerson = "person.fill"
        static let person = "person"
        static let scalemass = "scalemass"
        static let circleQuestion = "questionmark.circle"
        static let upChevron = "chevron.up"
        static let downChevron = "chevron.down"
        static let docOnDoc = "doc.on.doc"
        static let bell = "bell"
        static let key = "key"
        static let fillTray = "tray.fill"
        static let xmarkCircleFill = "xmark.circle.fill"
        static let circle = "circle"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let badgeBell = "bell.badge"
        static let lineRightArrow = "arrow.right.to.line"
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
        static let bookmark = "Bookmarks"
    }
    
    struct Placeholder {
        static let message = "Text Message"
    }

    struct Assets {
        static let app = "AppIcon"
        static let profile = "user.profile"
        static let emptyMessage = "message.empty"
        static let paperplane = "paperplane"
        static let emptyContent = "content.empty"
        static let google = "google"
        static let fillBookmark = "bookmark.fill"
        static let bookmark = "bookmark"
        static let fillPost = "post.selected"
        static let brokenHeart = "heart.broken"
        static let eye = "eye"
        static let slashEye = "eye.slash"
    }
    
    struct Miscellaneous {
        static let next = "Next"
        static let evidence = "Evidence Based"
        static let edit = "Edited"
    }
    
    struct Alerts {
        
        struct Title {
            static let deleteConversation = "Delete Conversation"
            static let deleteMessage = "Delete Message"
            static let resendMessage = "Resend This Message"
            static let clearRecents = "Clear Recent Searches"
            static let resetPassword = "Success"
        }
        
        struct Subtitle {
            static let deleteAlert = "This conversation will be deleted from your inbox. Other pople in the conversation will still be able to see it."
            static let clearRecents = "Are you sure you want to clear your most recent searches?"
            static let resetPassword = "We have sent password recover instruction to your email."
        }
    }
    
    struct Menu {
        static let deleteMessage = "Delete Message"
        static let resendMessage = "Try Sending Again"
        static let sharePhoto = "Share Photo"
        static let copy = "Copy"
        
    }
    
    struct SideMenu {
        static let profile = "Profile"
        static let bookmark = "Bookmarks"
        static let create = "Create"
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
        static let joinContent = "Our healthcare professional and student application is designed to connect individuals who are interested in healthcare-related topics. To ensure that the application is used by the intended audience, we have identified three categories of users who are eligible to join.\n\n• Healthcare Professionals (e.g. physicians, nurses, dentists, pharmacists, allied health professionals)\n• Healthcare Students (e.g. medical students, nursing students, dental students, allied health students)\n• Retired Healthcare Professionals."
        static let emailChangeTitle = "Account Rules"
        static let emailChangeContent = "In order to provide a seamless account management experience, please be aware that you can only modify accounts that are not associated with Google or Apple. If you signed up or logged in using your Google or Apple credentials, we regret to inform you that account changes, including email address updates, are not available through this feature.\n For accounts created with email and password credentials, you can freely make changes such as updating your email address or making adjustments to your in-app preferences. However, if you initially signed up or logged in using your Google or Apple account, your account information, including your email address, is managed by those respective services."
        static let passwordChangeTitle = "Password Rules"
        static let passwordChangeContent = "In order to provide a seamless account management experience, please be aware that you can only modify passwords that are not associated with Google or Apple. If you signed up or logged in using your Google or Apple credentials, we regret to inform you that account changes are not available through this feature.\n For accounts created with email and password credentials, you can freely make changes such as updating your email address or making adjustments to your in-app preferences. However, if you initially signed up or logged in using your Google or Apple account, your account information, including your email address, is managed by those respective services."
        static let commentTitle = "Notice Rules"
        static let commentContent = "We may occasionally include a notification to provide additional context regarding user actions. When a comment or reply is deleted, a message will appear as a placeholder within the conversation thread. This promotes transparency and informs users that a comment has been removed. Deleted comments or replies will be permanently deleted from your account, including their contents, associated metadata, and any publicly available analytical information."
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
    
    struct Opening {
        static let phrase = "Elevate your medical practice through shared experiences"
        static let googleSignIn = "Continue with Google"
        static let appleSignIn = "Continue with Apple"
        static let logIn = "Log in"
        static let logOut = "Log Out"
        static let createAccount = "Create account"
        static let or = "or"
        static let member = "Have an account already?"
        
        static let logInEmailTitle = "To get started, first enter your email"
        static let logInEmailPlaceholder = "Email"
        static let logInPasswordTitle = "Enter your password"
        static let logInPasswordPlaceholder = "Password"
        
        static let registerEmailTitle = "What's your email?"
        static let registerPasswordTitle = "Add a password"
        
        static let signUp = "Sign up"
        
        static let forgotPassword = "Trouble logging in?"
        
        static let passwordTitle = "Find your account"
        static let passwordContent = "Enter the email associated with your account to change your password."
        
        static let reactivateAccount = "Reactivate your account?"
        static let reactivateAccountAction = "Yes, reactivate"
        
        static let discipline = "Discipline"
        static let fieldOfStudy = "Field of Study"
      
        static let legal = "By signing up, you agree to our " + AppStrings.Legal.terms + ", " + AppStrings.Legal.privacy + ", " + AppStrings.Legal.cookie + "."
        
        static let categoryTitle = "Choose your main category"
        
        static func deactivateAccountMessage(withDeactivationDate deactivationDate: String, withDeadlineDate deadlineDate: String) -> String {
            return "You deactivated your account on \(deactivationDate). On \(deadlineDate), it will no longer be possible for you to restore your account if it was accidentally or wrongfully deactivated. By clicking \"Yes, reactivate\", you will halt the deactivation process and reactivate your account."
        }
    }
    
    struct Profile {
        static let bannerTitle = "Pick a banner"
        static let bannerContent = "Posting a banner picture is optional, but as Napoleon Bonaparte said, \"a picture is worth a thousand words.\""
        static let updated = "Your profile is updated"
        static let see = "See profile"
    }
    
    struct Legal {
        static let privacy = "Privacy Policy"
        static let terms = "Terms"
        static let cookie = "Cookie Policy"
    }
    
    struct App {
        static let appName = "MyEvidens"
        static let contactMail = "support@myevidens.com"
        static let support = "Contact Support"
    }
    
    struct URL {
        static let privacy = "https://www.apple.com"
        static let terms = "https://www.google.com"
        static let cookie = "https://www.twitch.tv"
    }
    
    struct Settings {
        static let accountTitle = "Your Account"
        static let accountContent = "Access details about your account or explore the available choices for deactivating your account."
        static let notificationsTitle = "Notifications"
        static let notificationsContent = "Select the kinds of notifications you get about your activities, interests, and recommendations."
        
        static let accountInfoTitle = "Account Information"
        static let accountInfoContent = "See your account information like your email address and your in-app condition."
        static let accountPasswordTitle = "Change Password"
        static let accountPasswordContent = "Change your password at any time."
        static let accountDeactivateTitle = "Deactivate your Account"
        static let accountDeactivateContent = "Find out on how you can deactivate your account"
    }
    
    struct Error {
        static let title = "Error"
        static let unknown = "Oops, something went wrong. Please try again later."
        
        static let emailFormat = "The email address is badly formatted. Please enter a valid email address."
        static let network = "Something went wrong. Check your connection and try again."
        static let userNotFound = "Sorry, we could not find your account."
        static let userFound = "This email has already been taken. Please sign in instead."
        
        static let requests = "Too many sign-in attempts. Please try again later."
        static let password = "Incorrect password. Please double-check and try again."
        static let weakPassword = "The given password is invalid. Password should be at least 8 characters."
        
        static let notFound = "Sorry, the requested item is no longer available."
    }
    
    struct Health {
        
        struct Category {
            static let professional = "Professional"
            static let student = "Student"
        }
        
        struct Discipline {
            static let medicine = "Medicine"
            static let odontology = "Odontology"
            static let pharmacy = "Pharmacy"
            static let physiotherapy = "Physiotherapy"
            static let nursing = "Nursing"
            static let veterinary = "Veterinary Medicine"
            static let psychology = "Psychology"
            static let podiatry = "Podiatry"
            static let nutrition = "Human Nutrition & Dietetics"
            static let optics = "Optics & Optometry"
            static let biomedical = "Biomedical Science"
            static let physical = "Physical Activity & Sport Science"
            static let speech = "Speech Therapy"
        }
    }
}
