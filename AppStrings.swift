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
        static let title = "Appearance"
        static let dark = "Dark Mode"
        static let system = "Use Device Settings"
        static let light = "Light Mode"
        static let content = "Set Dark mode to use the Light or Dark selection located in your device Display & Brightness settings."
    }
    
    struct Global {
        static let done = "Done"
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let add = "Add"
        static let go = "Continue"
        static let skip = "Skip for now"
        static let help = "Help"
        static let save = "Save"
    }
    
    struct Characters {
        static let dot = " • "
        static let hyphen = " - "
    }
    
    struct Icons {
        static let pin = "pin"
        static let fillPin = "pin.fill"
        static let trash = "trash"
        static let fillTrash = "trash.fill"
        static let pencil = "pencil"
        static let copy = "doc"
        static let share = "square.and.arrow.up"
        static let plus = "plus"
        static let leftChevron = "chevron.left"
        static let rightChevron = "chevron.right"
        static let exclamation = "exclamationmark"
        static let fillExclamation = "exclamationmark.circle.fill"
        static let clockwiseArrow = "arrow.clockwise"
        static let backArrow = "arrow.backward"
        static let note = "note"
        static let flag = "flag"
        static let scribble = "scribble"
        static let rightArrow = "arrow.right"
        static let moon = "moon.stars"
        static let sun = "sun.max"
        static let gear = "gearshape"
        static let upArrow = "arrow.up"
        static let paperplane = "paperplane"
        static let apple = "applelogo"
        static let fillPerson = "person.fill"
        static let clock = "clock"
        static let person = "person"
        static let ellipsis = "ellipsis"
        static let lock = "lock"
        static let camera = "camera"
        static let scalemass = "scalemass"
        static let circleQuestion = "questionmark.circle"
        static let upChevron = "chevron.up"
        static let downChevron = "chevron.down"
        static let docOnDoc = "doc.on.doc"
        static let bell = "bell"
        static let key = "key"
        static let fillTray = "tray.fill"
        static let photo = "photo"
        static let xmarkCircleFill = "xmark.circle.fill"
        static let xmark = "xmark"
        static let circle = "circle"
        static let fillCamera = "camera.fill"
        static let leftUpArrow = "arrow.up.left"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let xmarkPersonFill = "person.fill.xmark"
        static let badgeBell = "bell.badge"
        static let lineRightArrow = "arrow.right.to.line"
        static let car = "car"
        static let cropPerson = "person.crop.rectangle"
        static let rectangle = "rectangle"
        static let eyeGlasses = "eyeglasses"
        static let fillEuropeGlobe = "globe.europe.africa.fill"
        static let checkmark = "checkmark"
        static let magnifyingglass = "magnifyingglass"
        static let graduationcap = "graduationcap"
        static let filledInsetCircle = "circle.inset.filled"
        static let rightArrowCircleFill = "arrow.right.circle.fill"
        static let fillHeart = "heart.fill"
        static let heart = "heart"
        static let circlePlus = "plus.circle"
        static let book = "book"
        static let minus = "minus"
    }
    
    struct Actions {
        static let pin = "Pin"
        static let unpin = "Unpin"
        static let copy = "Copy"
        static let share = "Share"
        static let remove = "Remove"
        static let skip = "Skip"
    }
    
    struct Title {
        static let conversation = "Conversations"
        static let message = "Messages"
        static let newMessage = "New Message"
        static let user = "Add User"
        static let bookmark = "Bookmarks"
        static let clinicalCase = "Case"
        static let replies = "Replies"
        static let search = "Search"
        static let account = "Account"
        static let connect = "Connect"
        static let likes = "Likes"
        static let section = "Add Section"
    }
    
    struct Placeholder {
        static let message = "Text Message"
    }

    struct Assets {
        static let app = "AppIcon"
        static let profile = "user.profile"
        static let banner = "user.banner"
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
        static let privacyProfile = "user.profile.privacy"
        static let comment = "comment"
        static let image = "image"
    }
    
    struct Miscellaneous {
        static let next = "Next"
        static let evidence = "Evidence Based"
        static let edited = "Edited"
        static let edit = "Edit"
        static let change = "Change"
        static let apply = "Select all that apply"
        static let gotIt = "Got it"
        static let great = "Great"
        static let exclamationGreat = "Great!"
        static let allGood = "All good"
        static let submit = "Submit"
        static let goBack = "Go Back"
        static let context = "Add additional context"
        static let capsLoading = "LOADING"
        static let capsCopied = "COPIED"
        static let show = "Show"
        static let showMore = "show more"
        static let reset = "Reset"
        static let on = "On"
        static let off = "Off"
        static let clear = "Clear"
        static let you = "You"
        static let andOthers = "and others"
        static let elapsed = "elapsed"
        
        static let and = "and"
        static let others = "others"
        
        static let media = "Media"
    }
    
    struct Alerts {

        struct Title {
            static let deleteConversation = "Delete Conversation"
            static let deleteNotification = "Delete Notification"
            static let deleteMessage = "Delete Message"
            static let resendMessage = "Resend This Message"
            static let clearRecents = "Clear Recent Searches"
            static let resetPassword = "Success"
            static let deleteComment = "Delete Comment"
            static let deleteExperience = "Delete Experience"
            static let deleteEducation = "Delete Education"
            static let deletePatent = "Delete Patent"
            static let deletePublication = "Delete Publication"
            static let deleteLanguage = "Delete Language"
            static let deactivate = "Deactivate Account"
            static let deactivateLower = "Deactivate"
            static let deactivateCaps = "DEACTIVATE"
            static let deactivateWarning = "This action will deactivate your account. Are you sure?"
        }
        
        struct Subtitle {
            static let deleteConversation = "This conversation will be deleted from your inbox. Other pople in the conversation will still be able to see it."
            static let logout = "Are you sure you want to log out?"
            static let clearRecents = "Are you sure you want to clear your most recent searches?"
            static let resetPassword = "We have sent password recover instruction to your email."
            static let network = "Turn Off Airplane Mode or Use Wi-Fi to Access Data"
            static let deletePost = "Are you sure you want to delete this Post?"
            static let deleteComment = "Are you sure you want to delete this Comment?"
            static let reportPost = "Are you sure you want to report this Post to our moderation team?"
            static let deleteExperience = "Are you sure you want to delete this experience from your profile?"
            static let deleteEducation = "Are you sure you want to delete this education from your profile?"
            static let deletePatent = "Are you sure you want to delete this patent from your profile?"
            static let deletePublication = "Are you sure you want to delete this publication from your profile?"
            static let deleteLanguage = "Are you sure you want to delete this language from your profile?"
            static let deactivate = "Your account will be deactivated."
            static let deactivateWarning = "Your account will be deactivated. Please, type DEACTIVATE to confirm."

        }
        
        struct Actions {
            static let settings = "Settings"
            static let ok = "OK"
            static let unfollow = "Unfollow"
            static let follow = "Follow"
            static let following = "Following"
            static let deactivate = "Yes, deactivate"
            static let confirm = "Yes, confirm"
        }
    }
    
    struct PopUp {
        static let addCase = "The case has been marked as solved and your diagnosis has been added."
        static let solvedCase = "The case has been marked as solved."
        
        static let evidenceUrlError = "Apologies, but the URL you entered seems to be incorrect."
        
        static let deleteComment = "Your comment has been deleted."
        
        static let reportSent = "Your report has been received and will be analyzed promptly"
    }
    
    struct Menu {
        static let deleteMessage = "Delete Message"
        static let resendMessage = "Try Sending Again"
        static let sharePhoto = "Share Photo"
        static let copy = "Copy"
        static let importCamera = "Import from Camera"
        static let chooseGallery = "Choose from Gallery"
        
        static let deletePost = "Delete Post"
        static let editPost = "Edit Post"
        static let reportPost = "Report Post"
        static let reference = "Show Reference"
        
        static let goBack = "Go Back"
        static let reportComment = "Report Comment"
        static let deleteComment = "Delete Comment"
        
        static let deleteCase = "Delete Case"
        static let revisionCase = "Add Revision"
        static let solve = "Solve Case"
        static let reportCase = "Report Case"
    }
    
    struct SideMenu {
        static let profile = "Profile"
        static let bookmark = "Bookmarks"
        static let create = "Create"
        
        static let settingsAndLegal = "Settings & Legal"
        static let helpAndSupport = "Help & Support"
        
        static let settings = "Settings"
        static let legal = "Legal"
        static let about = "About Us"
        static let contact = "Contact Us"
    }
    
    struct Reference {
        static let quote = "Quote"
        static let linkTitle = "Link Reference"
        static let linkContent = "The content you are viewing is backed up by a web link that provides evidence supporting the ideas and concepts presented."
        static let citationTitle = "Complete Citation"
        static let citationContent = "The content you are viewing is supported by a reference that provides evidence supporting the ideas and concepts presented."
        static let quoteContent = "You can easily and accurately add quotes to your content using two referencing options: web links or author references.\n\nBy using these referencing options, you can ensure proper attribution and support your content with credible sources."
        static let verify = "Tap to verify the link"
        
        static let addLink = "Add Web Link"
        static let addCitation = "Add Author Citation"
        
        static let webLinks = "Web Links"
        static let remove = "Remove Reference"
        static let linkEvidence = "Include research articles, scholarly publications, guidelines, educational videos, and other relevant resources, adhering to evidence-based practice principles."
        
        static let citationExample = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658"
        static let citationEvidence = "Enhance your content with credible author source. Examples of sources with authors may include research papers, scholarly articles, official reports, expert opinions, and other reputable publications."
        
        static let exploreCitation = "Explore Author Citation"
        static let exploreWeb = "Explore Web Source"
    }
    
    #warning("missing display")
    struct Display {
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
        
        struct Opening {
            static let title = "Report"
            static let content = "We value your feedback and want to ensure that our services meet your needs. To help us achieve this, we need you to answer a few questions so we can better understand what's going on in this account's profile or any of its content shared. You'll also have the option to add more information in your own words.\n\nWe take reports seriously. If we find a rule violation, we'll either ask the owner to remove the content or lock or suspend the account.\n\nYour input is crucial in helping us improve and enhance our services. Rest assured, your responses will be kept confidential and will only be used for research and development purposes. Thank you for taking the time to provide us with your valuable feedback."
            static let start = "Start Report"
        }
        
        struct Target {
            static let title = "Who is this report for?"
            static let content = "Sometimes we ask questions that require more information. This allows us to provide the person being targeted with additional resources, if needed."

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
            static let title = "What is happening to you?"
            static let content = "Rather than having you figure out what rule someone violated, we want to know what you’re experiencing or seeing. This helps us figure out what’s going on here and resolve the issue more quickly and accurately."
            
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
        
        struct Submit {
            static let title = "Let's confirm that we have this accurate"
            static let content = "Review the content you provided before submitting the report. You can always add more context to your report. This will be included in the report and might help to inform our rules and policies."
            static let summary = "Report summary"

            static let detailsTitle = "Would you like to include additional information?"
            static let detailsContent = "The report contains this information that could assist us in shaping our rules and policies. However, it's important to note that we cannot ensure that we'll act on the details presented here."
            
            static let details = "Add report details here..."
            
        }
    }
    
    struct Content {
        
        struct Post {
            static let share = "What would you like to share?"
            static let post = "Post"
            
            struct Feed {
                static let title = "Your personalized timeline"
                static let content = "Currently, it may seem empty, but this space won't remain void for long."
                static let start = "Get started"
            }
            
            struct Empty {
                static let emptyPostTitle = "No posts yet."
                static let postsWith = "Posts with"
                static let willShow = "will show up here."
                static func hashtag(_ hashtag: String) -> String {
                    return postsWith + " " + hashtag.replacingOccurrences(of: "hash:", with: "#") + " " + willShow
                }
            }
            
            struct Privacy {
                static let publicTitle = "Public"
                static let publicContent = "Anyone on MyEvidens"
            }
        }
        
        struct Case {
            static let clinicalCase = "Clinical Case"
            
            struct Share {
                static let shareTitle = "Assign disciplines"
                static let shareContent = "Choosing fitting categories improves healthcare collaboration, search, and navigation, aiding professionals in sharing valuable insights."
                
                static let title = "Title"
                static let description = "Description"
                static let details = "Details"
                static let privacy = "Images can help others interpretation on what has happened to the patinent. Protecting patient privacy is our top priority. Visit our Patient Privacy Policy."
                static let patientPrivacyPolicy = "Patient Privacy Policy"
                
                static let phaseTitle = "Has the case reached a resolution, or is it still an open case?"
                static let phaseContent = "When categorizing a clinical case, you are required to select a stage that represents the current status of the case. By marking the case as solved, you indicates that you have successfully resolved a clinical case and obtained a confirmed diagnosis. By marking the case as unsolved, you can seek assistance from the community, engaging in discussions and receiving input from peers."
                static let solved = "Share as Solved"
                static let unsolved = "Share as Unsolved"
                
                static let diagnosis = "Diagnosis"
                static let revision = "Revision"
                static let images = "Images"
                
                static let diagnosisTitle = "Contribute to the community by sharing your expertise and treatment details for the case."
                static let addDiagnosis = "Add Diagnosis"
                static let dismissDiagnosis = "Share without Diagnosis"
                static let diagnosisContent = "You can share treatment details and conclusions to offer valuable insights to others. Please remember that adding a diagnosis is optional."
                
                static let addDiagnosisTitle = "Add your diagnosis and treatment details"
                static let addDiagnosisContent = "Add the diagnosis, observations, or any significant developments to keep others informed. Please note that for anonymously shared cases, the diagnosis will also remain anonymous."
                static let skip = "Skip Diagnosis"
                
            }

            struct Item {
                static let general = "General Case"
                static let teaching = "Teaching Interest"
                static let common = "Common Presentation"
                static let uncommon = "Uncommon Presentation"
                static let new = "New Disease"
                static let rare = "Rare Disease"
                static let diagnostic = "Diagnostic Dilemma"
                static let multidisciplinary = "Multidisciplinary Care"
                static let technology = "Medical Technology"
                static let strategies = "Treatment Strategies"
            }
            
            struct Revision {
                static let diagnosisContent = "The author has added a diagnosis."
                static let revisionContent = "The author has added a revision."
                static let progressTitle = "Add progress and new insights."
                static let progressContent = "Add new findings, observations, or any significant developments to keep others informed.\nPlease note that for anonymously shared cases, the progress updates will also remain anonymous."
            }
            
            
            struct Phase {
                static let solved = "Solved"
                static let unsolved = "Unsolved"
            }
            
            struct Privacy {
                static let regularTitle = "Public"
                static let anonymousTitle = "Anonymous"
                static let anonymousCase = "Anonymous Case"
                static let regularContent = "Your profile information will be visible"
                static let anonymousContent = "Only your profession and speciality will be visible"
            }
            
            struct Empty {
                static let emptyCaseTitle = "No cases yet."
                static let casesWith = "Cases with"
                static let showUp = "will show up here."
                static func hashtag(_ hashtag: String) -> String {
                    return casesWith + " " + hashtag.replacingOccurrences(of: "hash:", with: "#") + " " + showUp
                }
                static let emptyRevisionTitle = "This case does not have any revisions —— yet."
                static let emptyRevisionContent = "Would you like to share more information or any new findings? Add a revision to keep others informed about your progress."
                
                static let emptyFeed = "Nothing to see here —— yet."
                static let emptyFeedContent = "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here."
                static let share = "Share Case"
            }
            
            struct Filter {
                static let explore = "Explore"
                static let all = "All"
                static let recents = "Recents"
                static let you = "For You"
                static let solved = "Solved"
                static let unsolved = "Unsolved"
                
                static let disciplines = "Browse Disciplines"
            }
        }
        
        struct Comment {
            static let voice = "Voice your thoughts here..."
            static let emptyTitle = "Be the first to comment"
            static let emptyCase = "This case has no comments, but it won't be that way for long. Take the lead in commenting."
            static let emptyPost = "This post has no comments, but it won't be that way for long. Take the lead in commenting."
            
            static let delete = "Comment deleted"
            
            static let deleted = "This comment was deleted by the author."
            
            static let comments = "comments"
            static let comment = "comment"
        
        }
        
        struct Reply {
            static let delete = "Reply deleted"
            static let author = "Author"
        }
        
        struct Message {
            static let emptyTitle = "You are not following anyone."
            static let emptySearchTitle = "We couldn't find any user that match your criteria. Try searching for something else."
            static let emptyContent = "Start growing your network and start conversations."
            
            
            static let failure = "Message Send Failure"
            static let sending = "Sending"
            static let failed = "Not Delivered"

            static let yesterday = "Yesterday"
            static let today = "Today"
        }
        
        struct User {
            static let emptyTitle = "No users found"
            static let emptyContent = "Check back later for new user suggestions."
        }
        
        struct Bookmark {
            static let emptyCaseTitle = "No saved cases yet."
            static let emptyPostTitle = "No saved posts yet."
            static let emptyCaseContent = "Cases you save will show up here."
            static let emptyPostContent = "Posts you save will show up here."
        }
        
        struct Headers {
            static let apply = "Select all that apply"
            static let privacy = "Privacy"
        }
        
        struct Filters {
            static let emptyTitle = "No content found"
            static let emptyContent = "Try removing some filters or rephrasing your search"
            static let recents = "Recently searched"
        }
        
        struct Empty {
            static let learn = "Learn More"
            static let dismiss = "Dismiss"
            static let remove = "Remove Filters"
            static let comment = "Comment"
        }
        
        struct Search {
            static let seeAll = "See All"
            static let postsForYou = "Posts for you"
            static let casesForYou = "Cases for you"
            static let whoToFollow = "Who to follow"
        }
    }
    
    struct Search {
    
        struct Topics {
            static let people = "People"
            static let posts = "Posts"
            static let cases = "Cases"
        }
        
        struct Bar {
            static let message = "Search Direct Messages"
            static let members = "Search Members"
        }
    }
    
    struct User {
        struct Changes {
            static let email = "We sent you an email"
            static let password = "Your password is updated"
            static let deactivate = "Your account is deactivated"
            
            static let emailContent = "We have sent you the instructions to your new email address to successfully complete the process. Please note that after finishing the process, you may be required to log in again."
            static let passwordContent = "From now on, you will be able to use this new password to log in to your account."
            static let deactivateContent = "Sorry to see you go. #GoodBye"
            
            static let phase = "phase"
            static let login = "login"
            static let pass = "password"
            
            static let currentPassword = "Current Password"
            static let newPassword = "New Password"
            static let confirmPassword = "Confirm Password"
            static let passwordRules = "At least 8 characters"
            
            static let identity = "Verify Account"
            static let pending = "Verify your account now"
            static let review = "Reviewing"
            static let verified = "Verified"
               
            static let googleTitle = "Credentials Change Unavailable"
            static let appleTitle = "Credentials Change Unavailable"
            
            static let googleContent = "You are currently logged in with Google services. Changing credentials is not available for this type of account."
            static let appleContent = "You are currently logged in using your Apple ID. Changing credentials is unavailable for Apple accounts."
            static let undefined = "Oops, something went wrong. Please try again later."
            
            static let changesRules = "Please note that only non-Google and non-Apple accounts can be modified in this section."
            static let missmatch = "The two given passwords do not match"
            static let passLength = "Your password needs to be at least 8 characters. Please enter a longer one"
            static let verifyRules = "We place a high priority on verifying our users, as we strongly believe in upholding a secure and trustworthy environment for all our members."
            
            static let passwordId = "password"
            static let googleId = "google.com"
            static let appleId = "apple.com"

            static let loginGoogle = "This email is registered with Google services. Please log in using the Google option."
            static let loginApple = "This email is registered with Apple services. Please log in using the Apple option."
            
            static let condition = "Condition"
            
            static let deactivateProcess = "You're about to start the process of deactivating your account. As a result, your display name, and public profile will no longer be accessible or visible."
            static let deactivateResults = "This action will result in the deactivation of your account"
            static let deactivateDetails = "Some important details you should know"
            static let restore = "You can restore your account if it was accidentally or wrongfully deactivated for up to 30 days after deactivation."
            
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
        
        static let registerNameTitle = "What's your name?"
        static let registerNameContent = "This will be displayed on your profile as your full name. You can always change that later."
        static let registerFirstName = "First name"
        static let registerLastName = "Last name"
        
        static let registerIdentityTitle = "Almost there"
        
        static let registerIdentityProfesionalContent = "To proceed with the sign up process, we kindly request verification of your professional credentials."
        static let registerIdentityStudentContent = "To proceed with the sign up process, we kindly request verification of your student status."
        
        static let registerIdentityID = "We will need you to take a picture of your ID or any other form of ID - such as driving licence or passport."
        
        static let registerIdentitySkip = "Skip the verification process and do it later. Most features will be locked until your account is verified."
        static let verifyNow = "Verify now"
        
        static let finishRegister = "We will review your documents and grant you access to all our features."
        
        static let verifyDocs = "Professional Card, NHS Staff Card, Diploma or Certificate"
        static let verifyId = "ID, Driving Licence or Passport"
        static let verifyStudentDocs = "Student Enrollment, Registration or Tuition."
        static let verifyQualityCheck = "Ensure crystal-clear document details with no blur or glare."
        static let tryAgain = "Oops! Try again for a picture-perfect shot."
        
        static let signUp = "Sign up"
        
        static let forgotPassword = "Trouble logging in?"
        
        static let passwordTitle = "Find your account"
        static let passwordContent = "Enter the email associated with your account to change your password."
        
        static let reactivateAccount = "Reactivate your account?"
        static let reactivateAccountAction = "Yes, reactivate"
        
        static let discipline = "Discipline"
        static let fieldOfStudy = "Field of Study"
        static let speciality = "Speciality"
        static let specialities = "Specialities"
        
        static let agree = "By signing up, you agree to our"
        static let deactivateDate = "You deactivated your account on"
        static let on = "On"
        static let deactivateContent = "it will no longer be possible for you to restore your account if it was accidentally or wrongfully deactivated. By clicking \"Yes, reactivate\", you will halt the deactivation process and reactivate your account."
        
        static let categoryTitle = "Choose your main category"
        
        static let legal = agree + " " + AppStrings.Legal.terms + ", " + AppStrings.Legal.privacy + ", " + AppStrings.Legal.cookie + "."
        static func deactivateAccountMessage(withDeactivationDate deactivationDate: String, withDeadlineDate deadlineDate: String) -> String {
            return deactivateDate + " " + deactivationDate + ". " + on + " " + deactivateContent
        }
    }
    
    struct Profile {
        static let bannerTitle = "Pick a banner"
        static let bannerContent = "Posting a banner picture is optional, but as Napoleon Bonaparte said, \"a picture is worth a thousand words.\""
        static let editProfile = "Edit Profile"
        static let imageTitle = "Pick a profile picture"
        static let imageContent = "Posting a profile photo is optional, but it helps your connections and others to recognize you."
        static let updated = "Your profile is updated"
        static let see = "See profile"
        static let view = "View profile"
        
        static let interests = "Do you have  an interest in other fields or disciplines?"
        static let besides = "Besides"
        static let otherInterests = "what are your interests?. Interests are used to personalize your experience and will not be visible or shared on your profile."

        struct Post {
            static let emptyTitle = "You havn't posted lately"
            static let emptyContent = "You will be able to see your posts here."
            
            static let othersEmptyTitle = "hasn't posted lately."
            static let othersEmptyContent = "You will be able to see their posts here."
            
            static let posted = "posted this"
        }
        
        struct Case {
            static let emptyTitle = "You havn't shared any case lately"
            static let emptyContent = "You will be able to see your cases here."
            
            static let othersEmptyTitle = "hasn't shared any case lately."
            static let othersEmptyContent = "You will be able to see their cases here."

            static let shared = "shared this"
        }
        
        struct Comment {
            static let emptyTitle = "You havn't commented lately"
            static let emptyContent = "You will be able to see your comments here."
            
            static let othersEmptyTitle = "hasn't commented lately."
            static let othersEmptyContent = "You will be able to see their comments here."

            static let onThis = "on this"
            
            static let commented = "commented"
            static let replied = "replied on a comment"
        }

        static func interestsContent(withDiscipline discipline: Discipline) -> String {
            return besides + " " + discipline.name  + ", " + otherInterests
        }
    }
    
    struct Sections {
        static let title = "Configure custom sections"
        static let content = "Build on custom sections to your profile will  help you grow your network, get discovered easily and build more relationships"
        
        static let aboutTitle = "About yourself"
        static let aboutContent = "Your about me section briefly summarize the most important information you want to showcase."
        static let aboutPlaceholder = "Add about here..."
        
        static let experienceContent = "Your experience section lets you add, change, or remove a job, internship or contract position among others."
        static let languageContent = "Adding languages you know will make you stand out in your industry."
        
        static let category = "Category"
        
        static let firstName = "Enter your first name"
        static let lastName = "Enter your last name"
        
        static let setUp = "Let's get you set up"
        static let know = "See who you already know on MyEvidens. You can also complete your profile to increase your discoverability"
        
        static let aboutSection = "About"
        static let experienceSection = "Experience"
        static let educationSection = "Education"
        static let patentSection = "Patent"
        static let publicationSection = "Publication"
        static let languageTitle = "Language"
        static let languagesTitle = "Languages"

        struct Language {
            static let proficiency = "Proficiency"
            
            static let english = "English"
            static let mandarin = "Mandarin"
            static let hindi = "Hindi"
            static let spanish = "Spanish"
            static let catalan = "Catalan"
            static let french = "French"
            static let basque = "Basque"
            static let aranese = "Aranese"
            static let romanian = "Romanian"
            static let galician = "Galician"
            static let russian = "Russian"
            static let portuguese = "Portuguese"
            
            static let elementary = "Elementary Proficiency"
            static let limited = "Limited Working Proficiency"
            static let general = "General Professional Proficiency"
            static let advanced = "Advanced Professional Proficiency"
            static let functionally = "Functionally Native Proficiency"
        }
    }
    
    struct Notifications {
        
        struct Display {
            static let likePost = "liked your post"
            static let likeCase = "liked your case"
            static let follow = "followed you"
            static let replyPost = "replied on your post"
            static let replyCase = "replied on your case"
        }
        
        struct Empty {
            static let title = "Nothing to see here —— yet."
            static let content = "Complete your profile and connect with people you know to start receive notifications about your activity."
        }
        
        struct Delete {
            static let title = "Notification successfully deleted"
        }
        
        struct Settings {
            static let repliesTitle = "Replies"
            static let likesTitle = "Likes"
            static let followersTitle = "New Followers"
            static let messagesTitle = "Direct Messages"
            static let trackCases = "Track Saved Cases"
            
            static let repliesContent = "Receive notifications when people reply to any of your content, including posts, cases and comments."
            static let likesContent = "Receive notifications when people like your posts, cases and comments."
            static let trackCasesContent = "Receive notifications for updates on the cases you have saved."
            
            static let repliesTarget = "Select which notifications you receive when people reply to any of your content, including posts, cases and comments."
            static let likesTarget = "Select which notifications you receive when people like your posts, cases and comments."
            
            static let activity = "Related to you and your activity"
            static let network = "Related to your network"
            static let myNetwork = "My Network"
            static let anyone = "From Anyone"
            
            static let tap = "Tap \"Notifications\""
            static let turn = "Turn \"Allow Notifications\" on"
        } 
    }
    
    struct Network {
        struct Empty {
            static let followersTitle = "Looking for followers?"
            static let followersContent = "When someone follows this account, they'll show up here."
           
            static func followingTitle(forName name: String) -> String {
                return name + " " + "isn't following anyone."
            }
            static let followingContent = "Once they follow accounts, they'll show up here."
        }
        
        struct Follow {
            static let followers = "followers"
            static let following = "following"
        }
        
        struct Issues {
            static let title = "You're Offline"
            static let content = "Turn off Airplane Mode or connect to Wi-Fi."
            static let tryAgain = "Try again"
        }
    }
    
    struct Legal {
        static let privacy = "Privacy Policy"
        static let terms = "Terms"
        static let cookie = "Cookie Policy"
        static let copyright = "Copyright © 2023."
        
        static let explore = "Explore our legal resources for valuable information and assistance with legal inquiries."
    }
    
    struct App {
        static let appName = "MyEvidens"
        static let contactMail = "support@myevidens.com"
        static let support = "Contact Support"
        
        static let assistance = "We're here to provide support and assistance for any questions or concerns you may have. Please let us know how we can assist you further."
    }
    
    struct URL {
        static let privacy = "https://www.apple.com"
        static let terms = "https://www.google.com"
        static let cookie = "https://www.twitch.tv"
        static let patientPrivacy = "https://youtube.com"
        static let pubmed = "https://pubmed.ncbi.nlm.nih.gov/28244479/"
        
        static let googleQuery = "https://www.google.com/search?q="
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
        
        static let turnNotificationsTitle = "Turn on notifications?"
        static let turnNotificationsContent = "To get notifications from us, you'll need to turn them on in your iOS Settings. Here's how:"
        static let openSettings = "Open iOS Settings"
        
        static let copy = "Easily copy our email by tapping it."
        
        static let enterPassord = "Re-enter your password to continue."
        static let confirmPassword = "Confirm your password"
        
        static let changeEmail = "Change your email"
        static let changeEmailContent = "Enter the email address you'd like to associate with your account. Your email is not displayed in your public profile."
        static let emailPlaceholder = "Email address"
        static let deactivatePassword = "Re-enter your password to complete your deactivation request."

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
        
        static let languageExists = "Language already exists in your profile. Try adding a new language."
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
            static let optics = "Optics and Optometry"
            static let biomedical = "Biomedical Science"
            static let physical = "Physical Activity and Sport Science"
            static let speech = "Speech Therapy"
            static let occupational = "Occupational Therapy".localized(key: "health.discipline.occupational")
        }

        struct Speciality {
            struct Medicine {
                static let generalMedicine = "General Medicine"
                static let academicMedicine = "Academic Medicine"
                static let allergologyMedicine = "Allergology"
                static let analysesMedicine = "Clinical Analyses"
                static let pathologicalMedicine = "Pathological Anatomy"
                static let anaesthesiologyMedicine = "Anaesthesiology and Resuscitation"
                static let angiologyMedicine = "Angiology and Vascular Surgery"
                static let digestiveMedicine = "Digestive System"
                static let biochemistryMedicine = "Clinical Biochemistry"
                static let cardiologyMedicine = "Cardiology"
                static let cardiovascularMedicine = "Cardiovascular Surgery"
                static let digestiveSurgeryMedicine = "General and Digestive System Surgery"
                static let oralMaxillofacialMedicine = "Oral and Maxillofacial Surgery"
                static let orthopaedicSurgeryMedicine = "Orthopaedic Surgery and Traumatology"
                static let paediatricMedicine = "Paediatric Surgery"
                static let plasticMedicine = "Plastic, Aesthetic and Reconstructive Surgery"
                static let thoracicMedicine = "Thoracic Surgery"
                static let dermatologyMedicine = "Medical and Surgical Dermatology"
                static let endocrinologyMedicine = "Endocrinology and Nutrition"
                static let pharmacologyMedicine = "Clinical Pharmacology"
                static let geriatricsMedicine = "Geriatrics"
                static let haematologyMedicine = "Haematology and Haemotherapy"
                static let immunologyMedicine = "Immunlogy"
                static let legalForensicMedicine = "Legal and Forensic Medicine"
                static let occupationalMedicine = "Occupational Medicine"
                static let familyMedicine = "Family and Community Medicine"
                static let physicalMedicine = "Physical Medicine and Rehabilitation"
                static let intensiveMedicine = "Intensive Care Medicine"
                static let internalMedicine = "Internal Medicine"
                static let nuclearMedicine = "Nuclear Medicine"
                static let preventiveMedicine = "Preventive Medicine and Public Health"
                static let microbiologyMedicine = "Microbiology and Parasitology"
                static let nephrologyMedicine = "Nephrology"
                static let pneumologyMedicine = "Pneumology"
                static let neurosurgeryMedicine = "Neurosurgery"
                static let neurophysiologyMedicine = "Clinical Neurophysiology"
                static let neurologyMedicine = "Neurology"
                static let obstetricsMedicine = "Obstetrics and Gynaecology"
                static let ophthalmologyMedicine = "Ophthalmology"
                static let oncologyMedicine = "Medical Oncology"
                static let radiationMedicine = "Radiation Oncology"
                static let otorhinolaryngology = "Otorhinolaryngology"
                static let paediatricsMedicine = "Paediatrics and Specific Areas"
                static let psychiatryMedicine = "Psychiatry"
                static let radiodiagnosticsMedicine = "Radiodiagnostics"
                static let rheumatologyMedicine = "Rheumatology"
                static let urologyMedicine = "Urology"
            }
         
            struct Odontology {
                static let generalOdontology = "General Odontology"
                static let academicOdontology = "Academic Odontology"
                static let paediatricOdontology = "Paediatric Odontology"
                static let endodontics = "Endodontics"
                static let orthodontics = "Orthodontics"
                static let prosthodontics = "Prosthodontics"
                static let periodontics = "Periodontics"
                static let maxillofacialSurgery = "Maxillofacial and Oral Surgery"
                static let maxillofacialRadiology = "Maxillofacial and Oral Radiology"
                static let oralPathology = "Oral and Maxillofacial Pathology"
                static let prothesis = "Dental Prothesis"
                static let aesthetics = "Dental Aesthetics"
            }
            
            struct Pharmacy {
                static let generalPharmacy = "General Pharmacy"
                static let academicPharmacy = "Academic Pharmacy"
                static let ambulatoriPharmacy = "Ambulatory Care Pharmacy"
                static let cardiologyPharmacy = "Cardiology Pharmacy"
                static let compoundedPharmacy = "Compounded Sterile Preparations Pharmacy"
                static let criticalPharmacy = "Critical Care Pharmacy"
                static let emergencyPharmacy = "Emergency Medicine Pharmacy"
                static let geriatricPharmacy = "Geriatric Pharmacy"
                static let infectiousPharmacy = "Infectious Diseases Pharmacy"
                static let nuclearPharmacy = "Nuclear Pharmacy"
                static let nutritionPharmacy = "Nutrition Support Pharmacy"
                static let oncologyPharmacy = "Oncology Pharmacy"
                static let pediatricPharmacy = "Pediatric Pharmacy"
                static let pharmacotherapy = "Pharmacotherapy"
                static let psychiatricPharmacy = "Psychiatric Pharmacy"
                static let organPharmacy = "Solid Organ Transplantation Pharmacy"
            }
            
            struct Physiotherapy {
                static let generalPhysiotherapy = "General Physiotherapy"
                static let academicPhysiotherapy = "Academic Physiotherapy"
                static let geriatricPhysiotherapy = "Geriatric"
                static let orthopaedicPhysiotherapy = "Orthopaedic"
                static let neurologyPhysiotherapy = "Neurology"
                static let pediatricPhysiotherapy = "Pediatric"
                static let oncologyPhysiotherapy = "Oncology"
                static let womensPhysiotherapy = "Women’s Health"
                static let electrophysiologicPhysiotherapy = "Electrophysiologic"
                static let sportsPhysiotherapy = "Sports"
                static let woundPhysiotherapy = "Wound Management"
            }
            
            struct Nursing {
                static let generalNurse = "General Nurse"
                static let registeredNurse = "Registered Nurse"
                static let cardiacNurse = "Cardiac Nurse"
                static let certifiedNurse = "Certified Registered Nurse Anesthetist"
                static let clinicalNurse = "Clinical Nurse Specialist"
                static let criticalNurse = "Critical Care Nurse"
                static let familyNurse = "Family Nurse Practitioner"
                static let geriatricNurse = "Geriatric Nursing"
                static let perioperativeNurse = "Perioperative Nurse"
                static let mentalNurse = "Mental Health Nurse"
                static let educatorNurse = "Nurse Educator"
                static let midwifeNurse = "Nurse Midwife"
                static let practitionerNurse = "Nurse Practitioner"
                static let oncologyNurse = "Oncology Nurse"
                static let pediatricNurse = "Pediatric Nurse"
                static let publicNurse = "Public Health Nurse"
            }
            
            struct Veterinary {
                static let generalVeterinary = "General Veterinary"
                static let academicVeterinary = "Academic Veterinary"
                static let animalWelfare = "Animal Welfare"
                static let behavioralVeterinary = "Behavioral Medicine"
                static let pharmacologyVeterinary = "Clinical Pharmacology"
                static let dentistryVeterinary = "Dentistry"
                static let dermatologyVeterinary = "Dermatology"
                static let emergencyVeterinary = "Emergency and Critical Care"
                static let internalVeterinary = "Internal Medicine"
                static let laboratoryVeterinary = "Laboratory Animal Medicine"
                static let microbiologyVeterinary = "Microbiology"
                static let nutritionVeterinary = "Nutrition"
                static let ophthalmologyVeterinary = "Ophthalmology"
                static let pathologyVeterinary = "Pathology"
                static let poultryVeterinary = "Poultry Veterinary Medicine"
                static let preventiveVeterinary = "Preventive Medicine"
                static let radiologyVeterinary = "Radiology"
                static let speciesVeterinary = "Species-specialized Veterinary Practice"
                static let sportsVeterinary = "Sports Medicine and Rehabilitation"
                static let surgeryVeterinary = "Surgery"
                static let toxicologyVeterinary = "Toxicology"
                static let zoologicalVeterinary = "Zoological Medicine"
            }

            
            struct Psychology {
                static let generalPsychology = "General Psychology"
                static let academicPsychology = "Academic Psychology"
                static let neuropsychology = "Clinical Neuropsychology"
                static let healthPsychology = "Clinical Health Psychology"
                static let psychoanalysis = "Psychoanalysis"
                static let schoolPsychology = "School Psychology"
                static let clinicalPsychology = "Clinical Psychology"
                static let childPsychology = "Clinical Child and Adolescent Psychology"
                static let counselingPsychology = "Counseling Psychology"
                static let industrialPsychology = "Industrial-Organizational Psychology"
                static let behavioralPsychology = "Behavioral and Cognitive Psychology"
                static let forensicPsychology = "Forensic Psychology"
                static let familyPsychology = "Couple and Family Psychology"
                static let geropsychology = "Geropsychology"
                static let policePsychology = "Police and Public Safety Psychology"
                static let sleepPsychology = "Sleep Psychology"
                static let rehabilitationPsychology = "Rehabilitation Psychology"
                static let mentalPsychology = "Serious Mental Illness Psychology"
                static let clinicalPsychopharmacology = "Clinical Psychopharmacology"
                static let addictionPsychology = "Addiction Psychology"
                static let sportPsychology = "Sport Psychology"
            }
            
            struct Podiatry {
                static let generalPodiatry = "General Podiatry"
                static let academicPodiatry = "Academic Podiatry"
                static let reconstructivePodiatry = "Reconstructive Surgery"
                static let medicinePodiatry = "Podiatric Medicine"
                static let orthopedicsPodiatry = "Podiatric Orthopedics"
                static let sportsPodiatry = "Podiatric Sports Medicine"
                static let riskPodiatry = "High-risk Wound Care"
                static let rheumatologyPodiatry = "Podiatric Rheumatology"
                static let neuropodiatry = "Neuropodiatry"
                static let oncopodiatry = "Oncopodiatry"
                static let vascularPodiatry = "Podiatric Vascular Medicine"
                static let dermatologyPodiatry = "Podiatric Dermatology"
                static let podoradiology = "Podoradiology"
                static let gerontologyPodiatry = "Podiatric Gerontology"
                static let diabetologyPodiatry = "Podiatric Diabetology"
                static let podopediatrics = "Podopediatrics"
                static let forensicPodiatry = "Forensic Podiatry"
            }
            
            struct Nutrition {
                static let generalNutrition = "General Nutrition & Dietetics"
                static let academicNutrition = "Academic Nutrition & Dietetics"
                static let clinicalNutrition = "Clinical Nutrition"
                static let communityNutrition = "Community Nutrition"
                static let proceduralExpertise = "Procedural Expertise"
                static let sportsNutrition = "Sports Nutritionist"
                static let pediatricNutrition = "Pediatric Nutritionist"
                static let gerontologicalNutrition = "Gerontological Nutritionist"
                static let renalNutrition = "Renal or Nephrology Nutritionist"
            }
            
            struct Optics {
                static let generalOptics = "General Optics & Optometry"
                static let academicOptics = "Academic Optics & Optometry"
                static let corneaContactLenses = "Cornea and Contact Lenses"
                static let ocularDisease = "Ocular Disease"
                static let opticsLowVision = "Low Vision"
                static let opticsPediatrics = "Pediatrics"
                static let opticsGeriatrics = "Geriatrics"
                static let opticsOptometry = "Neuro-Optometry"
                static let opticsVisionTherapy = "Behavioral Optometry and Vision Therapy"
            }
            
            struct Biomedical {
                static let generalBiomedical = "General Biomedical Science"
                static let academicBiomedical = "Academic Biomedical Science"
                static let engineeringBiomechanical = "Biomechanical Engineering"
                static let engineeringBiomedical = "Biomedical Engineering"
                static let clinicalBiochemistry = "Clinical Biochemistry"
                static let vascularScience = "Vascular Science"
                static let clinicalEngineering = "Clinical Engineering"
                static let medicalElectronics = "Medical Electronics"
                static let microbiology = "Microbiology"
            }
            
            struct Physical {
                static let generalSports = "General Sports and Science"
                static let academicSports = "Academic Physical Sports and Science"
                static let managementSports = "Sports Management"
                static let trainingSports = "Training and Sports Performance"
                static let healthSports = "Health and Quality of Life"
                static let recreationSports = "Sports Recreation and Leisure"
            }
            
            struct Speech {
                static let generalSpeech = "General Speech Therapy"
                static let academicSpeech = "Academic Speech Therapy"
                static let articulationSpeech = "Articulation and Phonology"
                static let languageSpeech = "Language Development"
                static let fluencySpeech = "Fluency"
                static let voiceSpeech = "Voice"
                static let oralSpeech = "Oral Motor and Swallowing Dysfunction"
                static let sensorSpeech = "Sensory Integration"
                static let autismSpeech = "Autism Spectrum"
                static let augmentativeSpeech = "Augmentative Communication"
            }
            
            struct Occupational {
                static let generalTherapy = "General Occupational Therapy"
                static let academicTherapy = "Academic Occupational Therapy"
                static let gerontologyTherapy = "Gerontology"
                static let mentalTherapy = "Mental Health"
                static let pediatricsTherapy = "Pediatrics"
                static let physicalTherapy = "Physical Rehabilitation"
                static let drivingTherapy = "Driving and Community Mobility"
                static let environmentalTherapy = "Environmental Modification"
                static let feedingTherapy = "Feeding, Eating, and Swallowing"
                static let lowVisionTherapy = "Low Vision"
                static let schoolTherapy = "School Systems"
            }
        }
    }
}
