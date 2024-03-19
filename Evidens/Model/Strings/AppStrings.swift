//
//  AppStrings.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/5/23.
//

import Foundation

/// A structure containing static strings used throughout the app.
struct AppStrings {
    
    struct Tab {
        static let network = "My Network".localized(key: "tab.network")
        static let cases = "Cases".localized(key: "tab.cases")
        static let notifications = "Notifications".localized(key: "tab.notifications")
        static let search = "Search".localized(key: "tab.search")
    }
    
    struct Global {
        static let done = "Done".localized(key: "global.done")
        static let cancel = "Cancel".localized(key: "global.cancel")
        static let delete = "Delete".localized(key: "global.delete")
        static let add = "Add".localized(key: "global.add")
        static let go = "Continue".localized(key: "global.go")
        static let skip = "Skip for now".localized(key: "global.skip")
        static let help = "Help".localized(key: "global.help")
        static let save = "Save".localized(key: "global.save")
        static let official = "Official Account".localized(key: "global.official")
        static let withdraw = "Withdraw".localized(key: "global.withdraw")
        static let apply = "Apply".localized(key: "global.apply")
        static let recommended = "Recommended".localized(key: "global.recommended")
    }
    
    struct Characters {
        static let dot = " • "
        static let hyphen = " - "
        static let twoPoint = ":"
        static let space = " "
        static let atSign = "@"
        static let smallDot = "."
    }
    
    struct Icons {
        static let circleA = "a.circle.fill"
        static let pin = "pin"
        static let fillPin = "pin.fill"
        static let trash = "trash"
        static let fillTrash = "trash.fill"
        static let pencil = "pencil"
        static let copy = "doc"
        static let fillEnvelope = "envelope.fill"
        static let envelope = "envelope"
        static let share = "square.and.arrow.up"
        static let slashSpeaker = "speaker.slash"
        static let plus = "plus"
        static let exclamationmarkCircleFill = "exclamationmark.circle.fill"
        static let leftChevron = "chevron.left"
        static let rightChevron = "chevron.right"
        static let exclamation = "exclamationmark"
        static let fillExclamation = "exclamationmark.circle.fill"
        static let clockwiseArrow = "arrow.clockwise"
        static let backArrow = "arrow.backward"
        static let downLeftArrow = "arrow.turn.down.left"
        static let note = "note"
        static let fireworks = "fireworks"
        static let fillFlag = "flag.fill"
        static let fillPaperplane = "paperplane.fill"
        static let flag = "flag"
        static let paperclip = "paperclip"
        static let scribble = "scribble"
        static let rightArrow = "arrow.right"
        static let moon = "moon.stars"
        static let sun = "sun.max"
        static let circleInfoFill = "info.circle.fill"
        static let gear = "gearshape"
        static let upArrow = "arrow.up"
        static let bubbleChar = "character.bubble"
        static let docPublication = "doc"
        static let paperplane = "paperplane"
        static let apple = "applelogo"
        static let fillPerson = "person.fill"
        static let clock = "clock"
        static let person = "person"
        static let checkmarkShield = "checkmark.shield"
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
        static let circleEllipsis = "ellipsis.circle"
        static let car = "car"
        static let compass = "line.3.horizontal"
        static let cropPerson = "person.crop.rectangle"
        static let rectangle = "rectangle"
        static let eyeGlasses = "eyeglasses"
        static let fillEuropeGlobe = "globe.europe.africa.fill"
        static let globe = "globe"
        static let checkmark = "checkmark"
        static let magnifyingglass = "magnifyingglass"
        static let graduationcap = "graduationcap"
        static let filledInsetCircle = "circle.inset.filled"
        static let rightArrowCircleFill = "arrow.right.circle.fill"
        static let fillHeart = "heart.fill"
        static let book = "book"
        static let heart = "heart"
        static let fillBook = "text.book.closed.fill"
        static let circlePlus = "plus.circle"
        static let circlePlusFill = "plus.circle.fill"
        static let minus = "minus"
        static let paintbrush = "paintbrush.pointed"
        static let switchArrow = "repeat"
        static let pawprint = "pawprint"
        static let cross = "cross"
        static let filter = "slider.horizontal.3"
        static let squareOnSquare = "square.on.square"
        static let network = "person.2.fill"
        static let fillBell = "bell.fill"
        static let clipboard = "list.clipboard.fill"
    }
    
    struct About {
        static let cooperate = "Cooperate with experienced professionals".localized(key: "about.cooperate")
        static let education = "Receive insights based on real cases and discussions".localized(key: "about.education")
        static let network = "Expand your professional network".localized(key: "about.network")
    }
    
    struct Actions {
        static let copy = "Copy".localized(key: "actions.copy")
        static let share = "Share".localized(key: "actions.share")
        static let remove = "Remove".localized(key: "actions.remove")
    }
    
    struct Title {
        static let bookmark = "Bookmarks".localized(key: "title.bookmark")
        static let clinicalCase = "Case".localized(key: "title.clinicalCase")
        static let replies = "Replies".localized(key: "title.replies")
        static let account = "Account".localized(key: "title.account")
        static let connect = "Connect".localized(key: "title.connect")
        static let likes = "Likes".localized(key: "title.likes")
        static let section = "Add Section".localized(key: "title.section")
        static let revision = "Case Revision".localized(key: "title.revision")
        static let sort = "Search filters".localized(key: "title.sort")
    }
    
    struct Placeholder {
        static let message = "Text Message".localized(key: "placeholder.message")
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
        static let link = "link"
        static let privacyProfile = "user.profile.privacy"
        static let comment = "comment"
        static let image = "image"
        static let blackLogo = "logo.black"
        static let whiteLogo = "logo.white"
        static let home = "home"
        static let selectedHome = "home.selected"
        static let cases = "cases"
        static let selectedCases = "cases.selected"
        static let fillPencil = "pencil.fill"
        static let pencil = "pencil"
        static let post = "post"
        static let selectedPost = "post.selected"
        static let notification = "notifications"
        static let selectedNotification = "notifications.selected"
        static let search = "search"
        static let caseGuideline = "case.guideline"
        static let caseDiscipline = "case.discipline"
        static let caseBody = "case.body"
        static let placeholderContent = "content.placeholder"
        static let postGuideline = "post.guideline"
        static let quote = "quote"
        static let fillQuote = "quote.fill"
        static let blackFrontBody = "blackFrontBody"
        static let whiteFrontBody = "whiteFrontBody"
        static let blackBackBody = "blackBackBody"
        static let whiteBackBody = "whiteBackBody"
        static let body = "body"
    }
    
    struct Miscellaneous {
        static let next = "Next".localized(key: "miscellaneous.next")
        static let evidence = "Evidence".localized(key: "miscellaneous.evidence")
        static let edited = "Edited".localized(key: "miscellaneous.edited")
        static let edit = "Edit".localized(key: "miscellaneous.edit")
        static let change = "Change".localized(key: "miscellaneous.change")
        static let apply = "Select all that apply".localized(key: "miscellaneous.apply")
        static let gotIt = "Got it".localized(key: "miscellaneous.gotIt")
        static let great = "Great".localized(key: "miscellaneous.great")
        static let exclamationGreat = "Great!".localized(key: "miscellaneous.exclamationGreat")
        static let allGood = "All good".localized(key: "miscellaneous.allGood")
        static let submit = "Submit".localized(key: "miscellaneous.submit")
        static let goBack = "Go Back".localized(key: "miscellaneous.goBack")
        static let context = "Add additional context".localized(key: "miscellaneous.context")
        static let capsCopied = "COPIED".localized(key: "miscellaneous.capsCopied")
        static let show = "Show".localized(key: "miscellaneous.show")
        static let on = "On".localized(key: "miscellaneous.on")
        static let off = "Off".localized(key: "miscellaneous.off")
        static let clear = "Clear".localized(key: "miscellaneous.clear")
        static let andOthers = "and others".localized(key: "miscellaneous.andOthers")
        static let elapsed = "elapsed".localized(key: "miscellaneous.elapsed")
        static let and = "and".localized(key: "miscellaneous.and")
        static let others = "others".localized(key: "miscellaneous.others")
        static let media = "Media".localized(key: "miscellaneous.media")
        static let date = "Date".localized(key: "miscellaneous.date")
        static let save = "Save changes".localized(key: "miscellaneous.save")
        static let smallAnd = "and".localized(key: "miscellaneous.smallAnd")
    }
    
    struct Alerts {

        struct Title {
            static let deleteNotification = "Delete Notification".localized(key: "alerts.title.deleteNotification")
            static let resetPassword = "Success".localized(key: "alerts.title.resetPassword")
            static let deletePost = "Delete Post".localized(key: "alerts.title.deletePost")
            static let deleteCase = "Delete Case".localized(key: "alerts.title.deleteCase")
            static let deleteComment = "Delete Comment".localized(key: "alerts.title.deleteComment")
            static let deleteLanguage = "Delete Language".localized(key: "alerts.title.deleteLanguage")
            static let deactivate = "Deactivate Account".localized(key: "alerts.title.deactivate")
            static let deactivateLower = "Deactivate".localized(key: "alerts.title.deactivateLower")
            static let deactivateCaps = "DEACTIVATE".localized(key: "alerts.title.deactivateCaps")
            static let deactivateWarning = "This action will deactivate your account. Are you sure?".localized(key: "alerts.title.deactivateWarning")
            static let faces = "Faces Detected".localized(key: "alerts.title.faces")
            
            static let withdraw = "Withdraw Invitation".localized(key: "alerts.title.withdraw")
            static let remove = "Remove Connection".localized(key: "alerts.title.remove")
            
            static let cancelContent = "Are you sure you want to quit this process?".localized(key: "alerts.title.cancelContent")
            
            static let skipBody = "Warning".localized(key: "alerts.title.skipBody")
            
            static let maxImages = "Oops! You have selected the maximum number of images allowed.".localized(key: "alerts.title.maxImages")
        }
        
        struct Subtitle {
            
            static let logout = "Are you sure you want to log out?".localized(key: "alerts.subtitle.logout")
            static let resetPassword = "We have sent password recover instruction to your email.".localized(key: "alerts.subtitle.resetPassword")
            static let network = "Turn Off Airplane Mode or Use Wi-Fi to Access Data".localized(key: "alerts.subtitle.network")
            static let deletePost = "Are you sure you want to delete this Post?".localized(key: "alerts.subtitle.deletePost")
            static let deleteCase = "Are you sure you want to delete this Case?".localized(key: "alerts.subtitle.deleteCase")
            static let deleteComment = "Are you sure you want to delete this Comment?".localized(key: "alerts.subtitle.deleteComment")
            static let reportPost = "Are you sure you want to report this Post to our moderation team?".localized(key: "alerts.subtitle.reportPost")
            static let deactivate = "Your account will be deactivated.".localized(key: "alerts.subtitle.deactivate")
            static let deactivateWarning = "Your account will be deactivated. Please, type DEACTIVATE to confirm.".localized(key: "alerts.subtitle.deactivateWarning")
            static let faces = "One or more face(s) have been detected. Please review your images or let us handle it for you.".localized(key: "alerts.subtitle.faces")
            static let unfollowPre = "Stop seeing posts from".localized(key: "alerts.subtitle.unfollowPre")
            static let unfollowPost = "on your feed.".localized(key: "alerts.subtitle.unfollowPost")
            static let unfollowAction = "won't be notified that you've unfollowed.".localized(key: "alerts.subtitle.unfollowAction")
            static let withdraw = "If you withdraw now, you won't be able to resend to this person for up to 3 weeks.".localized(key: "alerts.subtitle.withdraw")
            static let remove = "If you remove now, you won't be able to connect with this person for up to 5 weeks.".localized(key: "alerts.subtitle.remove")
            static let cancelContent = "The information you have just entered will not be saved.".localized(key: "alerts.subtitle.cancelContent")
            static let skipBody = "Leaving out the body part could affect case discovery based on body parts.".localized(key: "alerts.subtitle.skipBody")
            static let deleteError = "You cannot delete this case as others have invested time and effort into answering it.".localized(key: "alerts.subtitle.deleteError")
        }
        
        struct Actions {
            static let settings = "Settings".localized(key: "alerts.actions.settings")
            static let ok = "OK".localized(key: "alerts.actions.ok")
            static let unfollow = "Unfollow".localized(key: "alerts.actions.unfollow")
            static let follow = "Follow".localized(key: "alerts.actions.follow")
            static let following = "Following".localized(key: "alerts.actions.following")
            static let block = "Block".localized(key: "alerts.actions.block")
            static let unblock = "Unblock".localized(key: "alerts.actions.unblock")
            static let deactivate = "Yes, deactivate".localized(key: "alerts.actions.deactivate")
            static let confirm = "Yes, confirm".localized(key: "alerts.actions.confirm")
            static let quit = "Yes, quit".localized(key: "alerts.actions.quit")
        }
    }
    
    struct PopUp {
        static let addCase = "The case has been marked as solved and your diagnosis has been added".localized(key: "popUp.addCase")
        static let solvedCase = "The case has been marked as solved".localized(key: "popUp.solvedCase")
        static let caseRevision = "A new revision has been added to your case".localized(key: "popUp.caseRevision")
        static let evidenceUrlError = "Apologies, but the URL you entered seems to be incorrect".localized(key: "popUp.evidenceUrlError")
        static let deleteCase = "Your case has been deleted".localized(key: "popUp.deleteCase")
        
        static let deleteComment = "Your comment has been deleted".localized(key: "popUp.deleteComment")
        static let commentModified = "Your comment has been modified".localized(key: "popUp.commentModified")
        static let commentAdded = "Your comment has been sent".localized(key: "popUp.commentAdded")
        
        static let reportSent = "Your report has been received and will be analyzed promptly".localized(key: "popUp.reportSent")
        
        static let profileModified = "Your profile has been modified".localized(key: "popUp.profileModified")
        
        static let postAdded = "Your post has been sent".localized(key: "popUp.postAdded")
        static let postModified = "Your post has been modified".localized(key: "popUp.postModified")
        static let deletePost = "Your post has been deleted".localized(key: "popUp.deletePost")
        
        static let follow = "You are now following".localized(key: "popUp.follow")
        static let unfollow = "You are no longer following".localized(key: "popUp.unfollow")
        static let removeConnection = "You are no longer connected with".localized(key: "popUp.removeConnection")
        static let sendConnection = "Connection request sent to".localized(key: "popUp.sendConnection")
        static let acceptConnection = "Connection request accepted".localized(key: "popUp.acceptConnection")
        static let withdrawConnection = "Your connection request has been withdrawn".localized(key: "popUp.withdrawConnection")
        
        static let block = "has been blocked".localized(key: "popUp.block")
        
    }
    
    struct Menu {
        static let importCamera = "Import from Camera".localized(key: "menu.importCamera")
        static let chooseGallery = "Choose from Gallery".localized(key: "menu.chooseGallery")
        static let remove = "Remove current picture".localized(key: "menu.remove")
        static let deletePost = "Delete Post".localized(key: "menu.deletePost")
        static let editPost = "Edit Post".localized(key: "menu.editPost")
        static let reportPost = "Report Post".localized(key: "menu.reportPost")
        static let reference = "Show Reference".localized(key: "menu.reference")
        static let goBack = "Go Back".localized(key: "menu.goBack")
        static let reportComment = "Report Comment".localized(key: "menu.reportComment")
        static let deleteComment = "Delete Comment".localized(key: "menu.deleteComment")
        static let editComment = "Edit Comment".localized(key: "menu.editComment")
        static let deleteCase = "Delete Case".localized(key: "menu.deleteCase")
        static let revisionCase = "Add Revision".localized(key: "menu.revisionCase")
        static let solve = "Solve Case".localized(key: "menu.solve")
        static let reportCase = "Report Case".localized(key: "menu.reportCase")
        
        static let mediaProfile = "Your profile picture will be visible to everyone. People can view a larger version on your profile.".localized(key: "menu.mediaProfile")
        static let bannerProfile = "Your banner picture will be visible to everyone. People can view a larger version on your profile.".localized(key: "menu.bannerProfile")
    }
    
    struct SideMenu {
        static let profile = "Profile".localized(key: "sidemenu.profile")
        static let bookmark = "Bookmarks".localized(key: "sidemenu.bookmark")
        static let create = "Create".localized(key: "sidemenu.create")
        static let draft = "Drafts".localized(key: "sidemenu.drafts")
        
        static let settingsAndLegal = "Settings & Legal".localized(key: "sidemenu.settingsAndLegal")
        static let helpAndSupport = "Help & Support".localized(key: "sidemenu.helpAndSupport")
        static let settings = "Settings".localized(key: "sidemenu.settings")
        static let legal = "Legal".localized(key: "sidemenu.legal")
        static let about = "About Us".localized(key: "sidemenu.about")
        static let contact = "Contact Us".localized(key: "sidemenu.contact")
    }
    
    struct Reference {
        static let quote = "Quote".localized(key: "reference.quote")
        static let linkTitle = "Link Reference".localized(key: "reference.linkTitle")
        static let linkContent = "The content you are viewing is backed up by a web link that provides evidence supporting the ideas and concepts presented.".localized(key: "reference.linkContent")
        static let citationTitle = "Complete Citation".localized(key: "reference.citationTitle")
        static let citationContent = "The content you are viewing is supported by a reference that provides evidence supporting the ideas and concepts presented.".localized(key: "reference.citationContent")
        static let quoteContent = "You can easily and accurately add quotes to your content using two referencing options: web links or author references.\n\nBy using these referencing options, you can ensure proper attribution and support your content with credible sources.".localized(key: "reference.quoteContent")
        static let verify = "Tap to verify the link".localized(key: "reference.verify")
        static let addLink = "Add Web Link".localized(key: "reference.addLink")
        static let addCitation = "Add Author Citation".localized(key: "reference.addCitation")
        static let webLinks = "Web Links".localized(key: "reference.webLinks")
        static let remove = "Remove Reference".localized(key: "reference.veremoverify")
        static let linkEvidence = "Include research articles, scholarly publications, guidelines, educational videos, and other relevant resources, adhering to evidence-based practice principles.".localized(key: "reference.linkEvidence")
        static let citationExample = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658".localized(key: "reference.citationExample")
        static let citationEvidence = "Enhance your content with credible author source. Examples of sources with authors may include research papers, scholarly articles, official reports, expert opinions, and other reputable publications.".localized(key: "reference.citationEvidence")
        static let exploreCitation = "Explore Author Citation".localized(key: "reference.exploreCitation")
        static let exploreWeb = "Explore".localized(key: "reference.exploreWeb")
    }
    
    struct Report {
        
        struct Opening {
            static let title = "Report".localized(key: "report.opening.title")
            static let content = "We value your feedback and want to ensure that our services meet your needs. To help us achieve this, we need you to answer a few questions so we can better understand what's going on in this account's profile or any of its content shared. You'll also have the option to add more information in your own words.\n\nWe take reports seriously. If we find a rule violation, we'll either ask the owner to remove the content or lock or suspend the account.\n\nYour input is crucial in helping us improve and enhance our services. Rest assured, your responses will be kept confidential and will only be used for research and development purposes. Thank you for taking the time to provide us with your valuable feedback.".localized(key: "report.opening.content")
            static let start = "Start Report".localized(key: "report.opening.start")
        }
        
        struct Target {
            static let title = "Who is this report for?".localized(key: "report.target.title")
            static let content = "Sometimes we ask questions that require more information. This allows us to provide the person being targeted with additional resources, if needed.".localized(key: "report.target.content")

            static let myselfTitle = "Myself".localized(key: "report.target.myselfTitle")
            static let myselfContent = "The individual is either creating content that is directed towards themselves or consuming content that is personalized or tailored to their preferences.".localized(key: "report.target.myselfContent")
            static let myselfSummary = "This report is for me.".localized(key: "report.target.myselfSummary")
            static let groupTitle = "Someone else or a specific group of people".localized(key: "report.target.groupTitle")
            static let groupContent = "This content is directed at or mentions someone else or a specific group of people —— like racial or religious groups.".localized(key: "report.target.groupContent")
            static let groupSummary = "This report is for someone else or a specific group of people.".localized(key: "report.target.groupSummary")
            static let everyoneTitle = "Everyone".localized(key: "report.target.everyoneTitle")
            static let everyoneContent = "This content is isn't targeting a specific person or group, but it affects everyone —— like misleading information or sensitive content.".localized(key: "report.target.everyoneContent")
            static let everyoneSummary = "This report is for everyone.".localized(key: "report.target.everyoneSummary")
        }
        
        struct Topics {
            static let title = "What is happening to you?".localized(key: "report.topics.title")
            static let content = "Rather than having you figure out what rule someone violated, we want to know what you’re experiencing or seeing. This helps us figure out what’s going on here and resolve the issue more quickly and accurately.".localized(key: "report.topics.content")
            static let identityTitle = "Attacked because of the identity".localized(key: "report.topics.identityTitle")
            static let identityContent = "Slurs, misgendering, racist or sexist stereotypes, encouraging others to harass, sending hateful imagery or could risk identifying the patient.".localized(key: "report.topics.identityContent")
            static let harassTitle = "Harassed or intimidated with violence".localized(key: "report.topics.harassTitle")
            static let harrassContent = "Sexual harassment, group harassment, insults or name calling, posting private info, threatening to expose private into, violent event denial, violent threats, celebration of violent acts.".localized(key: "report.topics.harrassContent")
            static let spamTitle = "Spammed".localized(key: "report.topics.spamTitle")
            static let spamContent = "Posting malicious links, fake engagement, repetitive replies, or Direct Messages.".localized(key: "report.topics.spamContent")
            static let sensibleTitle = "Shown sensitive or disturbing content".localized(key: "report.topics.sensibleTitle")
            static let sensibleContent = "Posting graphic or violent content related to self-harm, suicide, or other sensitive topics, that could be triggering or harmful to some users.".localized(key: "report.topics.sensibleContent")
            static let evidenceTitle = "Lacking medical evidence or shown misleading information".localized(key: "report.topics.evidenceTitle")
            static let evidenceContent = "This content contains a claim that isn't supported by data.".localized(key: "report.topics.evidenceContent")
            static let tipsTitle = "Offered tips or currency - or encouraged to send them —— in a way that's deceptive or promotes or causes harm".localized(key: "report.topics.tipsTitle")
            static let tipsContent = "Behaviours that offer tips and incentives, encourage users to engage in deceptive practices, promote inappropriate content or Behaviours, or exploit the platform to earn rewards or other currencies.".localized(key: "report.topics.tipsContent")
        }
        
        struct Submit {
            static let title = "Let's confirm that we have this accurate".localized(key: "report.submit.title")
            static let content = "Review the content you provided before submitting the report. You can always add more context to your report. This will be included in the report and might help to inform our rules and policies.".localized(key: "report.submit.content")
            static let summary = "Report summary".localized(key: "report.submit.summary")
            static let detailsTitle = "Would you like to include additional information?".localized(key: "report.submit.detailsTitle")
            static let detailsContent = "The report contains this information that could assist us in shaping our rules and policies. However, it's important to note that we cannot ensure that we'll act on the details presented here.".localized(key: "report.submit.detailsContent")
            static let details = "Add report details here...".localized(key: "report.submit.details")
        }
    }
    
    struct Block {
        static let message = "will no longer be able to follow or connect with you, and you will not see notifications from".localized(key: "block.message")
        static let unblock = "will now be able to follow or connect with you, and you will see notifications from".localized(key: "block.unblock")
        
        static let emptyTitle = "Block unwated accounts".localized(key: "block.emptyTitle")
        static let emptyContent = "When you block someone, they won't be able to follow or connect with you, and you won't see notifications from them.".localized(key: "block.emptyContent")
    }
    
    struct Content {
        
        struct Post {
            static let share = "What's happening?".localized(key: "content.post.share")
            static let post = "Post".localized(key: "content.post.post")
            static let delete = "Post deleted".localized(key: "content.post.delete")
            static let deleted = "This post has been deleted by the post author.".localized(key: "content.post.deleted")
            static let hidden = "This post is no longer accessible as the user's account has been deactivated or deleted.".localized(key: "content.post.hidden")
            
            struct Feed {
                static let title = "Let's grow your network".localized(key: "content.post.feed.title")
                static let content = "Currently, it may seem empty, but this space won't remain void for long.".localized(key: "content.post.feed.content")
                static let start = "Get started".localized(key: "content.post.feed.start")
            }
            
            struct Empty {
                static let emptyPostTitle = "No posts yet.".localized(key: "content.post.empty.emptyPostTitle")
                static let postsWith = "Posts with".localized(key: "content.post.empty.postsWith")
                static let willShow = "will show up here.".localized(key: "content.post.empty.willShow")
                
                static func hashtag(_ hashtag: String) -> String {
                    return postsWith + " " + hashtag.replacingOccurrences(of: "hash:", with: "#") + " " + willShow
                }
            }
            
            struct Privacy {
                static let publicTitle = "Public".localized(key: "content.post.privacy.publicTitle")
                static let publicContent = "Anyone on Evidens".localized(key: "content.post.privacy.publicContent")
            }
        }
        
        struct Block {
            static let blockTitle = "is blocked".localized(key: "content.block.blockTitle")
            static let blockContent = "You can't connect or see any content from".localized(key: "content.block.blockContent")
            
            static let blockedTitle = "You're blocked".localized(key: "content.block.blockedTitle")
            static let blockedContent = "You can't connect or see any content from".localized(key: "content.block.blockedContent")
        }
        
        struct Case {
            static let clinicalCase = "Clinical Case".localized(key: "content.case.clinicalCase")
            static let delete = "Case deleted".localized(key: "content.case.delete")
            static let deleted = "This case was deleted by the case author.".localized(key: "content.case.deleted")
            
            struct Share {
                static let shareTitle = "Add disciplines".localized(key: "content.case.share.shareTitle")
                static let shareContent = "Choosing fitting disciplines improves healthcare collaboration, search, and navigation.".localized(key: "content.case.share.shareContent")
                
                static let bodyTitle = "Add the location".localized(key: "content.case.share.bodyTitle")
                static let bodySkip = "Can't provide such information".localized(key: "content.case.share.bodySkip")
                
                static let imageTitle = "Add images".localized(key: "content.case.share.imageTitle")
                static let imageContent = "Adding images is optional, but as Napoleon Bonaparte said, \"a picture is worth a thousand words\".".localized(key: "content.case.share.imageContent")

                static let title = "Title".localized(key: "content.case.share.title")
                static let description = "Description".localized(key: "content.case.share.description")
                static let details = "Details".localized(key: "content.case.share.details")
                static let privacy = "Images can help others interpretation on what has happened to the patient. Protecting patient privacy is our top priority. Visit our Patient Privacy Policy.".localized(key: "content.case.share.privacy")
                static let patientPrivacyPolicy = "Patient Privacy Policy".localized(key: "content.case.share.patientPrivacyPolicy")
                
                static let phaseTitle = "Is the case solved?".localized(key: "content.case.share.phaseTitle")
                static let phaseContent = "Opt for 'Solved' to share your expertise, showcasing your diagnosis and treatment details. If 'Unsolved,' invite collaborative assistance to gain insights.".localized(key: "content.case.share.phaseContent")
                static let solved = "Solved".localized(key: "content.case.share.solved")
                static let unsolved = "Unsolved".localized(key: "content.case.share.unsolved")
                
                static let diagnosis = "Diagnosis".localized(key: "content.case.share.diagnosis")
                static let revision = "Revision".localized(key: "content.case.share.revision")
                static let images = "Images".localized(key: "content.case.share.images")
                
                static let diagnosisTitle = "Elevate your case".localized(key: "content.case.share.diagnosisTitle")
                static let addDiagnosis = "Add diagnosis".localized(key: "content.case.share.addDiagnosis")
                static let dismissDiagnosis = "Share without diagnosis".localized(key: "content.case.share.dismissDiagnosis")
                static let diagnosisContent = "You can share your diagnosis and treatment details with others. Please note that adding a diagnosis is completely optional.".localized(key: "content.case.share.diagnosisContent")

                static let skip = "Skip Diagnosis".localized(key: "content.case.share.skip")
                
                static let accept = "Accept".localized(key: "content.case.share.accept")
                static let reject = "Reject".localized(key: "content.case.share.reject")
                
                static let caseNameTitle = "Add a title".localized(key: "content.case.share.caseNameTitle")
                static let caseNameContent = "The title stands as a cornerstone in a clinical case—concise and informative, serving as the first impression and a crucial filter for searches.".localized(key: "content.case.share.caseNameContent")
                
                static let caseDescriptionTitle = "Add a description".localized(key: "content.case.share.caseDescriptionTitle")
                static let caseDescriptionContent = "The description is a key element in a clinical case, offering a detailed narrative for a thorough understanding and aiding in targeted searches.".localized(key: "content.case.share.caseDescriptionContent")
                
                static let caseTraitsTitle = "Add traits".localized(key: "content.case.share.caseTraitsTitle")
                static let caseTraitsContent = "The identification of traits is a key element in a clinical case, providing detailed characteristics for a comprehensive understanding and facilitating targeted searches.".localized(key: "content.case.share.caseTraitsContent")
                
                static let privacyTitle = "One last thing...".localized(key: "content.case.share.privacyTitle")
                static let privacyContent = "For public cases, is accessible through your profile and prioritized in searches. For anonymous cases, only your discipline and specialty will be shared.".localized(key: "content.case.share.privacyContent")
                
                static let previewTitle = "Show the case preview".localized(key: "content.case.share.previewTitle")

                static let sentCaseContent = "To ensure patient privacy, every case is reviewed before being shared on Evidens. You'll be notified once your case is available.".localized(key: "content.case.share.sentCaseContent")
            }

            struct Item {
                static let general = "General Case".localized(key: "content.case.item.general")
                static let teaching = "Teaching Interest".localized(key: "content.case.item.teaching")
                static let common = "Common Presentation".localized(key: "content.case.item.common")
                static let uncommon = "Uncommon Presentation".localized(key: "content.case.item.uncommon")
                static let new = "New Disease".localized(key: "content.case.item.new")
                static let rare = "Rare Disease".localized(key: "content.case.item.rare")
                static let diagnostic = "Diagnostic Dilemma".localized(key: "content.case.item.diagnostic")
                static let multidisciplinary = "Multidisciplinary Care".localized(key: "content.case.item.multidisciplinary")
                static let technology = "Medical Technology".localized(key: "content.case.item.technology")
                static let strategies = "Treatment Strategies".localized(key: "content.case.item.strategies")
            }
            
            struct Revision {
                static let diagnosisContent = "Diagnosis".localized(key: "content.case.revision.diagnosisContent")
                static let revisionContent = "Revision".localized(key: "content.case.revision.revisionContent")
                static let progressContent = "Add new findings, observations, or any significant developments to keep others informed.\nPlease note that for anonymously shared cases, the revisions will also remain anonymous.".localized(key: "content.case.revision.progressContent")
            }
            
            struct Phase {
                static let solved = "Solved".localized(key: "content.case.phase.solved")
                static let unsolved = "Unsolved".localized(key: "content.case.phase.unsolved")
            }
            
            struct Privacy {
                static let regularTitle = "Public".localized(key: "content.case.privacy.regularTitle")
                static let anonymousTitle = "Anonymous".localized(key: "content.case.privacy.anonymousTitle")
                static let anonymousCase = "Anonymous Case".localized(key: "content.case.privacy.anonymousCase")
                static let regularContent = "Your profile information will be visible".localized(key: "content.case.privacy.regularContent")
                static let anonymousContent = "Only your discipline and speciality will be visible".localized(key: "content.case.privacy.anonymousContent")
            }
            
            struct Empty {
                static let emptyCaseTitle = "No cases yet.".localized(key: "content.case.empty.emptyCaseTitle")
                static let casesWith = "Cases with".localized(key: "content.case.empty.casesWith")
                static let showUp = "will show up here.".localized(key: "content.case.empty.showUp")
                static let emptyRevisionTitle = "This case does not have any revisions —— yet.".localized(key: "content.case.empty.emptyRevisionTitle")
                static let emptyRevisionContent = "Would you like to share more information or any new findings? Add a revision to keep others informed about your progress.".localized(key: "content.case.empty.emptyRevisionContent")
                static let emptyFeed = "Nothing to see here —— yet.".localized(key: "content.case.empty.emptyFeed")
                static let emptyFeedContent = "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here.".localized(key: "content.case.empty.emtpyFeedContent")
                static let share = "Share Case".localized(key: "content.case.empty.share")
                
                static func hashtag(_ hashtag: String) -> String {
                    return casesWith + " " + hashtag.replacingOccurrences(of: "hash:", with: "#") + " " + showUp
                }
            }
            
            struct Category {
                static let you = "For You".localized(key: "content.case.category.you")
                static let latest = "Latest".localized(key: "content.case.category.latest")
            }
            
            struct Filter {
                static let explore = "Explore".localized(key: "content.case.filter.explore")
                static let all = "All".localized(key: "content.case.filter.all")
                static let recents = "Recent".localized(key: "content.case.filter.recents")
                
                static let solved = "Solved".localized(key: "content.case.filter.solved")
                static let unsolved = "Unsolved".localized(key: "content.case.filter.unsolved")
                static let disciplines = "Browse Disciplines".localized(key: "content.case.filter.disciplines")
                static let specialities = "Browse Specialities".localized(key: "content.case.filter.specialities")
                static let body = "Human Body".localized(key: "content.case.filter.body")
            }
            
            struct Sort {
                static let sort = "Sort".localized(key: "content.case.sort.sort")
            }
        }
        
        struct Comment {
            static let voice = "Post your reply".localized(key: "content.comment.voice")
            static let emptyTitle = "No comments".localized(key: "content.comment.emptyTitle")
            static let emptyCase = "This case has no comments. Take the lead in commenting.".localized(key: "content.comment.emptyCase")
            static let emptyPost = "This post has no comments. Take the lead in commenting.".localized(key: "content.comment.emptyPost")
            static let delete = "Comment deleted".localized(key: "content.comment.delete")
            static let deleted = "This comment was deleted by the author.".localized(key: "content.comment.deleted")
            static let comments = "comments".localized(key: "content.comment.comments")
            static let comment = "comment".localized(key: "content.comment.comment")
        }
        
        struct Reply {
            static let delete = "Reply deleted".localized(key: "content.reply.delete")
            static let author = "Author".localized(key: "content.reply.author")
            static let theAuthor = "The case author".localized(key: "content.reply.theAuthor")
        }
        
        struct User {
            static let deletedTitle = "Deleted account".localized(key: "content.user.deletedTitle")
            static let deletedUsername = "DeletedAccount".localized(key: "content.user.deletedUsername")
        }
        
        struct Bookmark {
            static let emptyCaseTitle = "No saved cases yet.".localized(key: "content.bookmark.emptyCaseTitle")
            static let emptyPostTitle = "No saved posts yet.".localized(key: "content.bookmark.emptyPostTitle")
            static let emptyCaseContent = "Cases you save will show up here.".localized(key: "content.bookmark.emptyCaseContent")
            static let emptyPostContent = "Posts you save will show up here.".localized(key: "content.bookmark.emptyPostContent")
        }
        
        struct Likes {
            static let emptyLikesTitle = "No likes yet.".localized(key: "content.likes.emptyLikesTitle")
            static let emptyLikesContent = "Likes will show up here.".localized(key: "content.likes.emptyLikesContent")
        }
        
        struct Draft {
            static let emptyCaseTitle = "No draft cases yet.".localized(key: "content.draft.emptyCaseTitle")
            static let emptyCaseContent = "Draft cases will show up here.".localized(key: "content.draft.emptyCaseContent")
            static let reviewCase = "The case is beeing reviewed".localized(key: "content.draft.reviewCase")
        }
        
        struct Headers {
            static let privacy = "Privacy".localized(key: "content.headers.privacy")
        }
        
        struct Filters {
            static let emptyTitle = "No content found".localized(key: "content.filters.emptyTitle")
            static let emptyContent = "Try removing some filters or rephrasing your search".localized(key: "content.filters.emptyContent")
            static let recents = "Recently searched".localized(key: "content.filters.recents")
        }
        
        struct Empty {
            static let learn = "Learn More".localized(key: "content.empty.learn")
            static let dismiss = "Dismiss".localized(key: "content.empty.dismiss")
            static let remove = "Remove Filters".localized(key: "content.empty.remove")
            static let comment = "Comment".localized(key: "content.empty.comment")
        }
        
        struct Search {
            static let search = "Search for".localized(key: "content.search.search")
            static let seeAll = "See All".localized(key: "content.search.seeAll")
            static let postsForYou = "Posts for you".localized(key: "content.search.postsForYou")
            static let casesForYou = "Cases for you".localized(key: "content.search.casesForYou")
            static let people = "People".localized(key: "content.search.people")
            static let emptyTitle = "Nothing to see here —— yet.".localized(key: "content.search.emptyTitle")
            static let emptyContent = "It's empty now, but it won't be for long. Check back later to see the latest results.".localized(key: "content.search.emptyContent")
            static let results = "No results for".localized(key: "content.search.results")
            static let term = "The term you entered did not bring up any results. You may want to try using different search terms.".localized(key: "content.search.term")
        }
    }
    
    struct Search {
    
        struct Topics {
            static let featured = "Featured".localized(key: "search.topics.featured")
            static let people = "People".localized(key: "search.topics.people")
            static let posts = "Posts".localized(key: "search.topics.posts")
            static let cases = "Cases".localized(key: "search.topics.cases")
        }
        
        struct Bar {
            static let search = "Cases, posts, people...".localized(key: "search.bar.search")
            static let message = "Search Direct Messages".localized(key: "search.bar.message")
            static let members = "Search Connections".localized(key: "search.bar.members")
        }
        
        struct Empty {
            static let title = "Try searching for cases, posts, people or any of the above filters".localized(key: "search.empty.title")
        }
    }
    
    struct Guidelines {
        
        struct Case {
            static let guildelines = "See case sharing guidelines and best practices".localized(key: "guidelines.case.guildelines")
            static let title = "Case\nSharing".localized(key: "guidelines.case.title")
            static let summary = "Get insights instantly from Evidens network".localized(key: "guidelines.case.summary")
            static let work = "How it works?".localized(key: "guidelines.case.work")
            static let classify = "Classify".localized(key: "guidelines.case.classify")
            static let form = "Fill".localized(key: "guidelines.case.form")
            static let stage = "Phase".localized(key: "guidelines.case.stage")
            static let submit = "Submit".localized(key: "guidelines.case.submit")
            static let classifyContent = "Classify your case by incorporating all relevant disciplines and involved body parts.".localized(key: "guidelines.case.classifyContent")
            static let formContent = "Provide comprehensive information, including a title and detailed description.".localized(key: "guidelines.case.formContent")
            static let stageContent = "Indicate whether your case is unsolved or solved, and if applicable, a diagnosis.".localized(key: "guidelines.case.stageContent")
            static let submitContent = "Submit your case for a prompt review, ensuring no personal information is disclosed.".localized(key: "guidelines.case.submitContent")
            static let benefits = "Share your cases with the network to gain diverse insights. Whether solved or undiagnosed, each case serves a purpose, contributing to collective knowledge. Collaborate for comprehensive perspectives and improve patient outcomes.".localized(key: "guidelines.case.benefits")
            static let categorize = "Categorizing cases is crucial for accurate indexing, tagging, and timely notifications to relevant users. It ensures effective searchability for future reference, enhancing collaboration and optimizing the exchange of valuable insights within the network.".localized(key: "guidelines.case.categorize")
            static let body = "Assigning body parts to cases facilitates targeted sharing with relevant users, streamlining searches and enhancing overall efficiency in knowledge exchange within the network.".localized(key: "guidelines.case.body")
            static let go = "Let's go".localized(key: "guidelines.case.go")
            static let privacy = "If you're ready to share your own cases then read the Patient Privacy Policy and get started.".localized(key: "guidelines.case.privacy")
            
            static let content = "Share patient cases to improve patient outcomes.".localized(key: "guidelines.case.content")
        }
        
        struct Post {
            static let guildelines = "See post sharing guidelines and best practices".localized(key: "guidelines.post.guildelines")
            
            static let title = "Post\nSharing".localized(key: "guidelines.post.title")
            static let summary = "Have discussions, share research or ask questions".localized(key: "guidelines.post.summary")
            
            static let benefits = "Share your thoughts, engage in discussions, and contribute to a collaborative space where members can exchange valuable insights, research findings, and helpful guidelines.".localized(key: "guidelines.post.benefits")
            static let categorize = "Categorizing posts is crucial for accurate indexing and tagging as it ensures effective searchability for future reference.".localized(key: "guidelines.post.categorize")
            
            static let classify = "Classify".localized(key: "guidelines.post.classify")
            static let form = "Fill".localized(key: "guidelines.post.form")
            static let submit = "Post".localized(key: "guidelines.post.submit")
            
            static let classifyContent = "Classify your post by incorporating all relevant disciplines.".localized(key: "guidelines.post.classifyContent")
            static let formContent = "Provide comprehensive information, including media files, if needed.".localized(key: "guidelines.post.formContent")
            static let submitContent = "Share your post and start engaging with your network.".localized(key: "guidelines.post.submitContent")
            
            static let content = "Participate in discussions, share ideas, research and guidelines.".localized(key: "guidelines.post.content")
        }
    }
    
    struct User {
        struct Changes {
            static let email = "We sent you an email".localized(key: "user.changes.email")
            static let password = "Your password is updated".localized(key: "user.changes.password")
            static let deactivate = "Your account is deactivated".localized(key: "user.changes.deactivate")
            static let emailContent = "We have sent you the instructions to your new email address to successfully complete the process. Please note that after finishing the process, you may be required to log in again.".localized(key: "user.changes.emailContent")
            static let passwordContent = "From now on, you will be able to use this new password to log in to your account.".localized(key: "user.changes.passwordContent")
            static let deactivateContent = "Sorry to see you go. #GoodBye".localized(key: "user.changes.deactivateContent")
            static let phase = "phase"
            static let login = "login"
            static let pass = "password"
            static let currentPassword = "Current Password".localized(key: "user.changes.currentPassword")
            static let newPassword = "New Password".localized(key: "user.changes.newPassword")
            static let confirmPassword = "Confirm Password".localized(key: "user.changes.confirmPassword")
            static let passwordRules = "At least 8 characters".localized(key: "user.changes.passwordRules")
            static let identity = "Verify Account".localized(key: "user.changes.identity")
            static let pending = "Verify your account now".localized(key: "user.changes.pending")
            static let review = "Reviewing".localized(key: "user.changes.review")
            static let verified = "Verified".localized(key: "user.changes.verified")
            static let googleTitle = "Credentials Change Unavailable".localized(key: "user.changes.googleTitle")
            static let appleTitle = "Credentials Change Unavailable".localized(key: "user.changes.appleTitle")
            static let googleContent = "You are currently logged in with Google services. Changing credentials is not available for this type of account.".localized(key: "user.changes.googleContent")
            static let appleContent = "You are currently logged in using your Apple ID. Changing credentials is unavailable for Apple accounts.".localized(key: "user.changes.appleContent")
            static let undefined = "Oops, something went wrong. Please try again later.".localized(key: "user.changes.undefined")
            static let changesRules = "Please note that only non-Google and non-Apple accounts can be modified in this section.".localized(key: "user.changes.changeRules")
            static let equal = "The new password cannot be the same as your current password. Please choose a different password.".localized(key: "user.changes.equal")
            static let missmatch = "The two given passwords do not match".localized(key: "user.changes.missmatch")
            static let passLength = "Your password needs to be at least 8 characters. Please enter a longer one".localized(key: "user.changes.passLength")
            static let verifyRules = "We place a high priority on verifying our users, as we strongly believe in upholding a secure and trustworthy environment for all our members.".localized(key: "user.changes.verifyRules")
            
            static let passwordId = "password"
            static let googleId = "google.com"
            static let appleId = "apple.com"
            
            static let loginGoogle = "This email is registered with Google services. Please log in using the Google option.".localized(key: "user.changes.loginGoogle")
            static let loginApple = "This email is registered with Apple services. Please log in using the Apple option.".localized(key: "user.changes.loginApple")
            static let accountPhase = "Phase".localized(key: "user.changes.accountPhase")
            static let deactivateProcess = "You're about to start the process of deactivating your account. As a result, your display name, and public profile will no longer be accessible or visible.".localized(key: "user.changes.deactivateProcess")
            static let deactivateResults = "This will deactivate your account".localized(key: "user.changes.deactivateResults")
            static let deactivateDetails = "Some important details you should know".localized(key: "user.changes.deactivateDetails")
            static let restore = "You can restore your account if it was deactivated accidentally or mistakenly up to 30 days after deactivation. After the 30 days, your account and your data will be permanently deleted.\n\nRemember that you won't be able to log in or use any Evidens services, and you will lose all information directly linked to your account, such as saved items, drafts, or your clinical cases.\n\nYour posts, clinical cases, or comments may still be visible to others, but without showing any indication of your profile.\n\nSome account data may continue to be available on search engines, such as Google or Bing. Evidens does not control search results on third-party search engines.".localized(key: "user.changes.restore")
            static let username = "Sorry, username changes are not allowed. If you need to update your username, please contact support for assistance.".localized(key: "user.changes.username")
        }
    }
    
    struct Opening {
        static let phrase = "Elevate your clinical practice through shared experiences".localized(key: "opening.phrase")
        static let googleSignIn = "Continue with Google".localized(key: "opening.googleSignIn")
        static let appleSignIn = "Continue with Apple".localized(key: "opening.appleSignIn")
        static let logIn = "Log in".localized(key: "opening.logIn")
        static let logOut = "Log Out".localized(key: "opening.logOut")
        static let createAccount = "Create account".localized(key: "opening.createAccount")
        static let or = "or".localized(key: "opening.or")
        static let member = "Have an account already?".localized(key: "opening.member")
        static let logInEmailTitle = "To get started, first enter your email".localized(key: "opening.logInEmailTitle")
        static let logInEmailPlaceholder = "Email".localized(key: "opening.logInEmailPlaceholder")
        static let logInPasswordTitle = "Enter your password".localized(key: "opening.logInPasswordTitle")
        static let logInPasswordPlaceholder = "Password".localized(key: "opening.logInPasswordPlaceholder")
        static let registerEmailTitle = "What's your email?".localized(key: "opening.registerEmailTitle")
        static let registerPasswordTitle = "Add a password".localized(key: "opening.registerPasswordTitle")
        static let registerNameTitle = "What's your name?".localized(key: "opening.registerNameTitle")
        static let registerNameContent = "This will be displayed on your profile as your full name. You can always change that later.".localized(key: "opening.registerNameContent")
        static let registerFirstName = "First name".localized(key: "opening.registerFirstName")
        static let registerLastName = "Last name".localized(key: "opening.registerLastName")
        static let usernameTitle = "Add a username".localized(key: "opening.usernameTitle")
        static let usernameContent = "Your @username is unique to your account.".localized(key: "opening.usernameContent")
        static let usernamePlaceholder = "Username".localized(key: "opening.usernamePlaceholder")
        static let registerIdentityTitle = "Almost there".localized(key: "opening.registerIdentityTitle")
        static let registerIdentityProfesionalContent = "To proceed with the sign up process, we kindly request verification of your professional credentials.".localized(key: "opening.registerIdentityProfesionalContent")
        static let registerIdentityStudentContent = "To proceed with the sign up process, we kindly request verification of your student status.".localized(key: "opening.registerIdentityStudentContent")
        static let registerIdentityID = "We will need you to take a picture of your ID or any other form of ID - such as driving licence or passport.".localized(key: "opening.registerIdentityID")
        static let registerIdentitySkip = "Skip the verification process and do it later. Most features will be locked until your account is verified.".localized(key: "opening.registerIdentitySkip")
        static let verifyNow = "Verify now".localized(key: "opening.verifyNow")
        static let finishRegister = "We will review your documents and grant you access to all our features.".localized(key: "opening.finishRegister")
        static let verifyDocs = "Professional Card, NHS Staff Card, Diploma or Certificate".localized(key: "opening.verifyDocs")
        static let verifyId = "ID, Driving Licence or Passport".localized(key: "opening.verifyId")
        static let verifyStudentDocs = "Student Enrollment, Registration or Tuition.".localized(key: "opening.verifyStudentDocs")
        static let verifyQualityCheck = "Ensure crystal-clear document details with no blur or glare.".localized(key: "opening.verifyQualityCheck")
        static let tryAgain = "Oops! Try again for a picture-perfect shot.".localized(key: "opening.tryAgain")
        static let signUp = "Sign up".localized(key: "opening.signUp")
        static let forgotPassword = "Trouble logging in?".localized(key: "opening.forgotPassword")
        static let passwordTitle = "Find your account".localized(key: "opening.passwordTitle")
        static let passwordContent = "Enter the email associated with your account to change your password.".localized(key: "opening.passwordContent")
        static let reactivateAccount = "Reactivate your account?".localized(key: "opening.reactivateAccount")
        static let reactivateAccountAction = "Yes, reactivate".localized(key: "opening.reactivateAccountAction")
        static let banAccount = "Your account is permanently suspended".localized(key: "opening.banAccount")
        static let discipline = "Discipline".localized(key: "opening.discipline")
        static let fieldOfStudy = "Field of Study".localized(key: "opening.fieldOfStudy")
        static let speciality = "Speciality".localized(key: "opening.speciality")
        static let specialities = "Specialities".localized(key: "opening.specialities")
        static let agree = "By signing up, you agree to our".localized(key: "opening.agree")
        static let deactivateDate = "You deactivated your account on".localized(key: "opening.deactivateDate")
        static let on = "On".localized(key: "opening.on")
        static let deactivateContent = "it will no longer be possible for you to restore your account if it was accidentally or wrongfully deactivated.\n\nBy clicking \"Yes, reactivate\", you will halt the deactivation process and reactivate your account.".localized(key: "opening.deactivateContent")
        
        static let banContent = "After carefull review, we determined your account broke our rules. If you think we got this wrong, you can submit an appeal.".localized(key: "opening.banContent")
        
        static let categoryTitle = "Choose your main category".localized(key: "opening.categoryTitle")
        
        static let sentCase = "Your case has been sent".localized(key: "opening.sentCase")
        
        static let legal = agree + AppStrings.Characters.space + AppStrings.Legal.terms + AppStrings.Characters.space + AppStrings.Miscellaneous.smallAnd + AppStrings.Characters.space + AppStrings.Legal.privacy + "."

        static func deactivateAccountMessage(withDeactivationDate deactivationDate: String, withDeadlineDate deadlineDate: String) -> String {
            return deactivateDate + " " + deactivationDate + ". " + on + " " + deadlineDate + " " + deactivateContent
        }
    }
    
    struct Profile {
        static let bannerTitle = "Pick a banner".localized(key: "profile.bannerTitle")
        static let bannerContent = "Posting a banner picture is optional, but as Napoleon Bonaparte said, \"a picture is worth a thousand words\".".localized(key: "profile.bannerContent")
        static let editProfile = "Edit Profile".localized(key: "profile.editProfile")
        static let imageTitle = "Pick a profile picture".localized(key: "profile.imageTitle")
        static let imageContent = "Posting a profile photo is optional, but it helps your connections and others to recognize you.".localized(key: "profile.imageContent")
        static let updated = "Your profile is updated".localized(key: "profile.updated")
        static let see = "See profile".localized(key: "profile.see")
        static let view = "View profile".localized(key: "profile.view")
        static let interests = "Add interests".localized(key: "profile.interests")
        static let besides = "Besides".localized(key: "profile.besides")
        static let otherInterests = "what are your interests?. Interests are used to personalize your experience and will not be visible or shared on your profile.".localized(key: "profile.otherInterests")
        static let verify = "Whether you're a healthcare professional or a student, we only ask for this information to verify your healthcare credentials efficiently.".localized(key: "profile.verify")

        struct Comment {
            static let onThis = "on this".localized(key: "profile.comment.onThis")
            static let commented = "commented".localized(key: "profile.comment.commented")
            static let replied = "replied on a comment".localized(key: "profile.comment.replied")
        }

        static func interestsContent(withDiscipline discipline: Discipline) -> String {
            return besides + " " + discipline.name  + ", " + otherInterests
        }
        
        struct Section {
            static let post = "Posts".localized(key: "profile.section.post")
            static let cases = "Cases".localized(key: "profile.section.cases")
            static let reply = "Replies".localized(key: "profile.section.reply")
            static let about = "About me".localized(key: "profile.section.about")
        }
    }
    
    struct Username {
        static let admin = "admin"
        static let evidens = "evidens"
    }
    
    struct Sections {
        static let title = "Configure custom sections".localized(key: "sections.title")
        static let content = "Build on custom sections to your profile will  help you grow your network, get discovered easily and build more relationships".localized(key: "sections.content")
        static let aboutTitle = "About yourself".localized(key: "sections.aboutTitle")
        static let aboutContent = "Your about me section briefly summarize the most important information you want to showcase.".localized(key: "sections.aboutContent")
        static let aboutPlaceholder = "Add about here...".localized(key: "sections.aboutPlaceholder")
        static let websiteContent = "Adding a website helps enhance your profile with a platform to highlight important information, features, or interests.".localized(key: "sections.websiteContent")
        static let category = "Category".localized(key: "sections.category")
        static let firstName = "Enter your first name".localized(key: "sections.firstName")
        static let lastName = "Enter your last name".localized(key: "sections.lastName")
        static let setUp = "Let's get you set up".localized(key: "sections.setUp")
        static let know = "Complete your profile to increase your discoverability.".localized(key: "sections.know")
        static let aboutSection = "About".localized(key: "sections.aboutSection")
        static let websiteSection = "Website".localized(key: "sections.websiteSection")
    }

    struct Notifications {
        
        struct Display {
            static let likePost = "liked your post".localized(key: "notifications.display.likePost")
            static let likePostPlural = "liked your post".localized(key: "notifications.display.likePostPlural")
            static let likeCase = "liked your case".localized(key: "notifications.display.likeCase")
            static let likeCasePlural = "liked your case".localized(key: "notifications.display.likeCasePlural")
            static let connectionRequest = "is inviting you to connect".localized(key: "notifications.display.connectionRequest")
            static let replyPost = "commented on your post".localized(key: "notifications.display.replyPost")
            static let replyCase = "commented on your case".localized(key: "notifications.display.replyCase")
            static let replyComment = "replied on your comment".localized(key: "notifications.display.replyComment")
            static let likeReply = "liked your comment".localized(key: "notifications.display.likeReply")
            static let likeReplyPlural = "liked your comment".localized(key: "notifications.display.likeReplyPlural")
            static let connectionAccept = "has accepted your connection request".localized(key: "notifications.display.connectionAccept")
            static let caseVisible = "Your case has been approved\n".localized(key: "notifications.display.caseVisible")
            static let caseRevision = "added a new revision to one of their cases you saved".localized(key: "notifications.display.caseRevision")
            static let caseDiagnosis = "added a diagnosis to one of their cases you saved".localized(key: "notifications.display.caseDiagnosis")
        }
        
        struct Empty {
            static let title = "Nothing to see here —— yet.".localized(key: "notifications.empty.title")
            static let content = "Complete your profile and connect with people you know to start receive notifications about your activity.".localized(key: "notifications.empty.content")
        }
        
        struct Delete {
            static let title = "Notification successfully deleted".localized(key: "notifications.delete.title")
        }
        
        struct Settings {
            static let repliesTitle = "Replies".localized(key: "notifications.settings.repliesTitle")
            static let likesTitle = "Likes".localized(key: "notifications.settings.likesTitle")
            static let connectionsTitle = "New Connections".localized(key: "notifications.settings.connectionsTitle")
            static let messagesTitle = "Direct Messages".localized(key: "notifications.settings.messagesTitle")
            static let trackCases = "Track Saved Cases".localized(key: "notifications.settings.trackCases")
            static let repliesContent = "Receive notifications when people reply to any of your content, including posts, cases and comments.".localized(key: "notifications.settings.repliesContent")
            static let likesContent = "Receive notifications when people like your posts, cases and comments.".localized(key: "notifications.settings.likesContent")
            static let trackCasesContent = "Receive notifications for updates on the cases you have saved.".localized(key: "notifications.settings.trackCasesContent")
            static let repliesTarget = "Select which notifications you receive when people reply to any of your content, including posts, cases and comments.".localized(key: "notifications.settings.repliesTarget")
            static let likesTarget = "Select which notifications you receive when people like your posts, cases and comments.".localized(key: "notifications.settings.likesTarget")
            static let activity = "Related to you and your activity".localized(key: "notifications.settings.activity")
            static let network = "Related to your network".localized(key: "notifications.settings.network")
            static let myNetwork = "My Network".localized(key: "notifications.settings.myNetwork")
            static let anyone = "From Anyone".localized(key: "notifications.settings.anyone")
            static let tap = "Tap \"Notifications\"".localized(key: "notifications.settings.tap")
            static let turn = "Turn \"Allow Notifications\" on".localized(key: "notifications.settings.turn")
        }
    }
    
    struct Network {
        struct Empty {
            static let connection = "Looking for connections?".localized(key: "network.empty.connection")
            static let connectionContent = "Once someone connects with this account, they'll show up here.".localized(key: "network.empty.connectionContent")
            static let followersTitle = "Looking for followers?".localized(key: "network.empty.followersTitle")
            static let followersContent = "When someone follows this account, they'll show up here.".localized(key: "network.empty.followersContent")
            static let anyone = "Looking to follow new accounts?".localized(key: "network.empty.anyone")
            static let followingContent = "Once they follow accounts, they'll show up here.".localized(key: "network.empty.followingContent")
        }
        
        struct Follow {
            static let followers = "followers".localized(key: "network.follow.followers")
            static let following = "following".localized(key: "network.follow.following")
        }
        
        struct Connection {
            static let connections = "Connections".localized(key: "network.connection.connections")
            static let connection = "Connection".localized(key: "network.connection.connection")
            static let unconnected = "No Connections".localized(key: "network.connection.unconnected")
            static let connected = "Connected".localized(key: "network.connection.connected")
            static let pending = "Pending".localized(key: "network.connection.pending")
            static let received = "Accept".localized(key: "network.connection.received")
            static let none = "Connect".localized(key: "network.connection.none")
            static let ignore = "Ignore".localized(key: "network.connection.ignore")
            
            static let message = "Message".localized(key: "network.connection.message")
            
            
            struct Profile {
                static let connected = "and you are connected".localized(key: "network.connection.profile.connected")
                static let pending = "received your connection request".localized(key: "network.connection.profile.pending")
                static let received = "sent you a connection request".localized(key: "network.connection.profile.received")
                static let none = "Connect with".localized(key: "network.connection.profile.none")

                static let connectedContent = "Connected since".localized(key: "network.connection.profile.connectedContent")
                static let pendingContent = "Your request was sent on".localized(key: "network.connection.profile.pendingContent")
                static let receivedContent = "The invitation was sent on".localized(key: "network.connection.profile.receivedContent")
                static let noneContent = "If you follow someone, you'll be able to see their shares and updates on your Evidens feed. Connecting with someone also allows both of you to send messages.".localized(key: "network.connection.profile.noneContent")
            }
        }
        
        struct Issues {
            
            struct Featured {
                static let title = "Featured content isn't loading right now".localized(key: "network.issues.featured.title")
            }
            
            struct Post {
                static let title = "Posts aren't loading right now".localized(key: "network.issues.post.title")
            }
            
            struct Case {
                static let title = "Cases aren't loading right now".localized(key: "network.issues.case.title")
            }
            
            struct Preferences {
                static let title = "Preferences aren't loading right now".localized(key: "network.issues.preferences.title")
            }
            
            struct Users {
                static let title = "Users aren't loading right now".localized(key: "network.issues.users.title")
            }
            
            struct Comments {
                static let title = "Comments aren't loading right now".localized(key: "network.issues.comments.title")
            }
            
            struct Drafts {
                static let title = "Drafts aren't loading right now".localized(key: "network.issues.drafts.title")
            }

            static let tryAgain = "Try again".localized(key: "network.issues.tryAgain")
        }
    }
    
    struct Legal {
        static let privacy = "Privacy Policy".localized(key: "legal.privacy")
        static let terms = "Terms".localized(key: "legal.terms")
        static let copyright = "Copyright Evidens © 2024.".localized(key: "legal.copyright")
        static let explore = "Explore our legal resources for valuable information and assistance with legal inquiries.".localized(key: "legal.explore")
        static let privacyCenter = "Privacy Center".localized(key: "legal.privacyCenter")
        static let contact = "Contact us".localized(key: "legal.contact")
        
        static let activity = "Your activity on Evidens".localized(key: "legal.activity")
        static let content = "Get more information about privacy on Evidens".localized(key: "legal.content")
    }
    
    struct App {
        static let appName = "Evidens".localized(key: "app.appName")
        static let contactMail = "support@evidens.com"
        static let personalMail = "evidens.release@gmail.com"
        static let support = "Contact Support".localized(key: "app.support")
        static let assistance = "We're here to provide support and assistance for any questions or concerns you may have. Please let us know how we can assist you further.".localized(key: "app.assistance")
    }
    
    struct Permission {
        static let share = "Sharing cases and posts is restricted until your account is verified.".localized(key: "permission.share")
        static let profile = "Profile update is restricted until your account is verified.".localized(key: "permission.profile")
        static let connections = "Connections are restricted until your account is verified.".localized(key: "permission.connections")
        static let reaction = "Reactions are restricted until your account is verified.".localized(key: "permission.reaction")
        static let comment = "Commenting is restricted until your account is verified.".localized(key: "permission.comment")
    }
    
    struct Provider {
        static let google = "Google"
        static let apple = "Apple"
        static let password = "Email/Password".localized(key: "provider.password")
    }
    
    struct URL {
        static let url = "URL".localized(key: "url.url")
        static let privacy = "https://sites.google.com/view/evidensapp/privacy-policy"
        static let terms = "https://sites.google.com/view/evidensapp/terms-of-service"
        static let patientPrivacy = "https://sites.google.com/view/evidensapp/patient-privacy-policy"
        static let pubmed = "https://pubmed.ncbi.nlm.nih.gov/28244479/"
        
        static let googleQuery = "https://www.google.com/search?q="
        
        static let draftPrivacy = "https://sites.google.com/view/evidensapp/home"
    }
    
    struct Settings {
        static let accountTitle = "Your account".localized(key: "settings.accountTitle")
        static let accountContent = "Access details about your account or explore the available choices for deactivating your account.".localized(key: "settings.accountContent")
        static let privacyTitle = "Privacy and security".localized(key: "settings.privacyTitle")
        static let privacyContent = "Manage what information you see and share on Evidens.".localized(key: "settings.privacyContent")
        static let notificationsTitle = "Notifications".localized(key: "settings.notificationsTitle")
        static let notificationsContent = "Select the kinds of notifications you get about your activities, interests, and recommendations.".localized(key: "settings.notificationsContent")
        static let languageTitle = "Language".localized(key: "settings.languageTitle")
        static let languageContent = "Manage which language is used to personalize your Evidens experience.".localized(key: "settings.languageContent")
        static let resourcesTitle = "Additional resources".localized(key: "settings.resourcesTitle")
        static let resourcesContent = "Check out other places for helpful information to learn more about Evidens products and services.".localized(key: "settings.resourcesContent")
        static let accountInfoTitle = "Account information".localized(key: "settings.accountInfoTitle")
        static let accountInfoContent = "See your account information like your email address and your in-app condition.".localized(key: "settings.accountInfoContent")
        static let accountPasswordTitle = "Change password".localized(key: "settings.accountPasswordTitle")
        static let accountPasswordContent = "Change your password at any time.".localized(key: "settings.accountPasswordContent")
        static let accountDeactivateTitle = "Deactivate your account".localized(key: "settings.accountDeactivateTitle")
        static let accountDeactivateContent = "Find out on how you can deactivate your account.".localized(key: "settings.accountDeactivateContent")
        static let blockTitle = "Mute and block".localized(key: "settings.blockTitle")
        static let blockContent = "Manage the accounts you muted or blocked.".localized(key: "settings.blockContent")
        static let turnNotificationsTitle = "Turn on notifications?".localized(key: "settings.turnNotificationsTitle")
        static let turnNotificationsContent = "To get notifications from us, you'll need to turn them on in your iOS Settings. Here's how:".localized(key: "settings.turnNotificationsContent")
        static let openSettings = "Open iOS Settings".localized(key: "settings.openSettings")
        static let copy = "Easily copy our email by tapping it.".localized(key: "settings.copy")
        static let enterPassord = "Re-enter your password to continue.".localized(key: "settings.enterPassword")
        static let confirmPassword = "Confirm your password".localized(key: "settings.confirmPassword")
        static let changeEmail = "Change your email".localized(key: "settings.changeEmail")
        static let changeEmailContent = "Enter the email address you'd like to associate with your account. Your email is not displayed in your public profile.".localized(key: "settings.changeEmailContent")
        static let emailPlaceholder = "Email address".localized(key: "settings.emailPlaceholder")
        static let deactivatePassword = "Re-enter your password to complete your deactivation request.".localized(key: "settings.deactivatePassword")
    }
    
    struct Error {
        static let title = "Error".localized(key: "error.title")
        static let unknown = "Oops, something went wrong. Please try again later.".localized(key: "error.unknown")
        static let emailFormat = "The email address is badly formatted. Please enter a valid email address.".localized(key: "error.emailFormat")
        static let network = "Something went wrong. Check your connection and try again.".localized(key: "error.network")
        static let userNotFound = "Sorry, we could not find your account.".localized(key: "error.userNotFound")
        static let userFound = "This email has already been taken. Please sign in instead.".localized(key: "error.userFound")
        static let requests = "Too many sign-in attempts. Please try again later.".localized(key: "error.requests")
        static let password = "Incorrect password. Please double-check and try again.".localized(key: "error.password")
        static let weakPassword = "The given password is invalid. Password should be at least 8 characters.".localized(key: "error.weakPassword")
        static let notFound = "Sorry, the requested item is no longer available.".localized(key: "error.notFound")
        static let languageExists = "Language already exists in your profile. Try adding a new language.".localized(key: "error.languageExists")
        static let verified = "Only verified users can post content. Check back later to verify your status.".localized(key: "error.verified")
        static let message = "You can send messages only to your connections.".localized(key: "error.message")
        static let connection = "Invitation not sent. You can resend an invitation 3 weeks after withdrawing it.".localized(key: "error.connection")
        static let connection5 = "Invitation not sent. You can resend an invitation 5 weeks after withdrawing it.".localized(key: "error.connection5")
        static let connectionDeny = "Invitation not sent. Please try again later.".localized(key: "error.connectionDeny")
        static let editComment = "Please finish editing your current comment and try again.".localized(key: "error.editComment")
        static let reactivate = "Sorry, to reactivate your account, at least one day must have passed since it was deactivated.".localized(key: "error.reactivate")
        static let deactivate = "Sorry, to deactivate your account, at least one day must have passed since it was reactivated.".localized(key: "error.deactivate")
        static let available = "This page is no longer available".localized(key: "error.available")
        static let usernameLength = "Sorry, your username cannot be shorter than 4 characters or longer than 15 characters.".localized(key: "error.usernameLength")
        static let usernameCharacters = "Sorry, a username can only contain alphanumeric characters (letters A-Z, numbers 0-9) with the exception of underscores.".localized(key: "error.usernameCharacters")
        static let usernameKeyword = "Sorry, usernames containing the words Evidens or Admin cannot be claimed.".localized(key: "error.usernameKeyword")
        static let usernameUnique = "Sorry, this username has already been claimed. Please, select a new one.".localized(key: "error.usernameUnique")
        static let usernameChange = "The session has expired. Please sign in again to continue.".localized(key: "error.usernameChange")
    }
    
    struct Debug {
        static let finishRegister = "Lights, camera...".localized(key: "debug.finishRegister")
        static let finishRegisterContent = "Congratulations, you have completed our onboarding process. We hope you make the most of your experience and enjoy your journey with us.".localized(key: "debug.finishRegisterContent")
        static let version = "Version".localized(key: "debug.version")
        static let build = "Build"
        static let help = "Get help".localized(key: "debug.help")
        static let errorTitle = "Send error reports".localized(key: "debug.errorTitle")
        static let errorContent = "Automatically send error reports to Evidens service provider to help improve the application.".localized(key: "debug.errorContent")
        static let provider = "Provider".localized(key: "debug.provider")
        static let providerContent = "Your provider displays the method you used to sign up or log in to Evidens.".localized(key: "debug.providerContent")
    }
    
    struct Health {
        struct Category {
            static let professional = "Professional".localized(key: "health.category.professional")
            static let student = "Student".localized(key: "health.category.student")
        }
        
        struct Body {
            struct Human {
                struct Front {
                    static let head = "Front head".localized(key: "health.body.human.front.head")
                    static let rightShoulder = "Front right shoulder".localized(key: "health.body.human.front.rightShoulder")
                    static let leftShoulder = "Front left shoulder".localized(key: "health.body.human.front.leftShoulder")
                    static let rightChest = "Front right chest".localized(key: "health.body.human.front.rightChest")
                    static let leftChest = "Front left chest".localized(key: "health.body.human.front.leftChest")
                    static let stomach = "Stomach".localized(key: "health.body.human.front.stomach")
                    static let hips = "Front hips".localized(key: "health.body.human.front.hips")
                    static let rightThigh = "Front right thigh".localized(key: "health.body.human.front.rightThigh")
                    static let leftThigh = "Front left thigh".localized(key: "health.body.human.front.leftThigh")
                    static let rightKnee = "Front right knee".localized(key: "health.body.human.front.rightKnee")
                    static let leftKnee = "Front left knee".localized(key: "health.body.human.front.leftKnee")
                    static let rightShin = "Right shin".localized(key: "health.body.human.front.rightShin")
                    static let leftShin = "Left shin".localized(key: "health.body.human.front.leftShin")
                    static let rightFoot = "Right foot".localized(key: "health.body.human.front.rightFoot")
                    static let leftFoot = "Left foot".localized(key: "health.body.human.front.leftFoot")
                    static let rightArm = "Right arm".localized(key: "health.body.human.front.rightArm")
                    static let leftArm = "Left arm".localized(key: "health.body.human.front.leftArm")
                    static let rightHand = "Right hand".localized(key: "health.body.human.front.rightHand")
                    static let leftHand = "Left hand".localized(key: "health.body.human.front.leftHand")
                }
                
                struct Back {
                    static let head = "Back head".localized(key: "health.body.human.back.head")
                    static let rightShoulder = "Back left shoulder".localized(key: "health.body.human.back.rightShoulder")
                    static let leftShoulder = "Back right shoulder".localized(key: "health.body.human.back.leftShoulder")
                    static let rightChest = "Left upper back".localized(key: "health.body.human.back.rightChest")
                    static let leftChest = "Right upper back".localized(key: "health.body.human.back.leftChest")
                    static let stomach = "Lower back".localized(key: "health.body.human.back.stomach")
                    static let hips = "Back hips".localized(key: "health.body.human.back.hips")
                    static let rightThigh = "Back left thigh".localized(key: "health.body.human.back.rightThigh")
                    static let leftThigh = "Back right thigh".localized(key: "health.body.human.back.leftThigh")
                    static let rightKnee = "Back left knee".localized(key: "health.body.human.back.rightKnee")
                    static let leftKnee = "Back right knee".localized(key: "health.body.human.back.leftKnee")
                    static let rightShin = "Left calf".localized(key: "health.body.human.back.rightShin")
                    static let leftShin = "Right calf".localized(key: "health.body.human.back.leftShin")
                    static let rightFoot = "Back left foot".localized(key: "health.body.human.back.rightFoot")
                    static let leftFoot = "Back right foot".localized(key: "health.body.human.back.leftFoot")
                    static let rightArm = "Back left arm".localized(key: "health.body.human.back.rightArm")
                    static let leftArm = "Back right arm".localized(key: "health.body.human.back.leftArm")
                    static let rightHand = "Back left hand".localized(key: "health.body.human.back.rightHand")
                    static let leftHand = "Back right hand".localized(key: "health.body.human.back.leftHand")
                }
            }
        }
        
        struct Discipline {
            static let medicine = "Medicine".localized(key: "health.discipline.medicine")
            static let odontology = "Odontology".localized(key: "health.discipline.odontology")
            static let pharmacy = "Pharmacy".localized(key: "health.discipline.pharmacy")
            static let physiotherapy = "Physiotherapy".localized(key: "health.discipline.physiotherapy")
            static let nursing = "Nursing".localized(key: "health.discipline.nursing")
            static let veterinary = "Veterinary Medicine".localized(key: "health.discipline.veterinary")
            static let psychology = "Psychology".localized(key: "health.discipline.psychology")
            static let podiatry = "Podiatry".localized(key: "health.discipline.podiatry")
            static let nutrition = "Human Nutrition & Dietetics".localized(key: "health.discipline.nutrition")
            static let optics = "Optics and Optometry".localized(key: "health.discipline.optics")
            static let biomedical = "Biomedical Science".localized(key: "health.discipline.biomedical")
            static let physical = "Physical Activity and Sport Science".localized(key: "health.discipline.physical")
            static let speech = "Speech Therapy".localized(key: "health.discipline.speech")
            static let occupational = "Occupational Therapy".localized(key: "health.discipline.occupational")
        }

        struct Speciality {
            struct Medicine {
                static let generalMedicine = "General Medicine".localized(key: "health.speciality.medicine.generalMedicine")
                static let academicMedicine = "Academic Medicine".localized(key: "health.speciality.medicine.academicMedicine")
                static let allergologyMedicine = "Allergology".localized(key: "health.speciality.medicine.allergologyMedicine")
                static let analysesMedicine = "Clinical Analyses".localized(key: "health.speciality.medicine.analysesMedicine")
                static let pathologicalMedicine = "Pathological Anatomy".localized(key: "health.speciality.medicine.pathologicalMedicine")
                static let anaesthesiologyMedicine = "Anaesthesiology and Resuscitation".localized(key: "health.speciality.medicine.anaesthesiologyMedicine")
                static let angiologyMedicine = "Angiology and Vascular Surgery".localized(key: "health.speciality.medicine.angiologyMedicine")
                static let digestiveMedicine = "Digestive System".localized(key: "health.speciality.medicine.digestiveMedicine")
                static let biochemistryMedicine = "Clinical Biochemistry".localized(key: "health.speciality.medicine.biochemistryMedicine")
                static let cardiologyMedicine = "Cardiology".localized(key: "health.speciality.medicine.cardiologyMedicine")
                static let cardiovascularMedicine = "Cardiovascular Surgery".localized(key: "health.speciality.medicine.cardiovascularMedicine")
                static let digestiveSurgeryMedicine = "General and Digestive System Surgery".localized(key: "health.speciality.medicine.digestiveSurgeryMedicine")
                static let oralMaxillofacialMedicine = "Oral and Maxillofacial Surgery".localized(key: "health.speciality.medicine.oralMaxillofacialMedicine")
                static let orthopaedicSurgeryMedicine = "Orthopaedic Surgery and Traumatology".localized(key: "health.speciality.medicine.orthopaedicSurgeryMedicine")
                static let paediatricMedicine = "Paediatric Surgery".localized(key: "health.speciality.medicine.paediatricMedicine")
                static let plasticMedicine = "Plastic, Aesthetic and Reconstructive Surgery".localized(key: "health.speciality.medicine.plasticMedicine")
                static let thoracicMedicine = "Thoracic Surgery".localized(key: "health.speciality.medicine.thoracicMedicine")
                static let dermatologyMedicine = "Medical and Surgical Dermatology".localized(key: "health.speciality.medicine.dermatologyMedicine")
                static let endocrinologyMedicine = "Endocrinology and Nutrition".localized(key: "health.speciality.medicine.endocrinologyMedicine")
                static let pharmacologyMedicine = "Clinical Pharmacology".localized(key: "health.speciality.medicine.pharmacologyMedicine")
                static let geriatricsMedicine = "Geriatrics".localized(key: "health.speciality.medicine.geriatricsMedicine")
                static let haematologyMedicine = "Haematology and Haemotherapy".localized(key: "health.speciality.medicine.haematologyMedicine")
                static let immunologyMedicine = "Immunology".localized(key: "health.speciality.medicine.immunologyMedicine")
                static let legalForensicMedicine = "Legal and Forensic Medicine".localized(key: "health.speciality.medicine.legalForensicMedicine")
                static let occupationalMedicine = "Occupational Medicine".localized(key: "health.speciality.medicine.occupationalMedicine")
                static let familyMedicine = "Family and Community Medicine".localized(key: "health.speciality.medicine.familyMedicine")
                static let physicalMedicine = "Physical Medicine and Rehabilitation".localized(key: "health.speciality.medicine.physicalMedicine")
                static let intensiveMedicine = "Intensive Care Medicine".localized(key: "health.speciality.medicine.intensiveMedicine")
                static let internalMedicine = "Internal Medicine".localized(key: "health.speciality.medicine.internalMedicine")
                static let nuclearMedicine = "Nuclear Medicine".localized(key: "health.speciality.medicine.nuclearMedicine")
                static let preventiveMedicine = "Preventive Medicine and Public Health".localized(key: "health.speciality.medicine.preventiveMedicine")
                static let microbiologyMedicine = "Microbiology and Parasitology".localized(key: "health.speciality.medicine.microbiologyMedicine")
                static let nephrologyMedicine = "Nephrology".localized(key: "health.speciality.medicine.nephrologyMedicine")
                static let pneumologyMedicine = "Pulmonology".localized(key: "health.speciality.medicine.pneumologyMedicine")
                static let neurosurgeryMedicine = "Neurosurgery".localized(key: "health.speciality.medicine.neurosurgeryMedicine")
                static let neurophysiologyMedicine = "Clinical Neurophysiology".localized(key: "health.speciality.medicine.neurophysiologyMedicine")
                static let neurologyMedicine = "Neurology".localized(key: "health.speciality.medicine.neurologyMedicine")
                static let obstetricsMedicine = "Obstetrics and Gynaecology".localized(key: "health.speciality.medicine.obstetricsMedicine")
                static let ophthalmologyMedicine = "Ophthalmology".localized(key: "health.speciality.medicine.ophthalmologyMedicine")
                static let oncologyMedicine = "Medical Oncology".localized(key: "health.speciality.medicine.oncologyMedicine")
                static let radiationMedicine = "Radiation Oncology".localized(key: "health.speciality.medicine.radiationMedicine")
                static let otorhinolaryngology = "Otorhinolaryngology".localized(key: "health.speciality.medicine.otorhinolaryngology")
                static let paediatricsMedicine = "Paediatrics and Specific Areas".localized(key: "health.speciality.medicine.paediatricsMedicine")
                static let psychiatryMedicine = "Psychiatry".localized(key: "health.speciality.medicine.psychiatryMedicine")
                static let radiodiagnosticsMedicine = "Radiodiagnostics".localized(key: "health.speciality.medicine.radiodiagnosticsMedicine")
                static let rheumatologyMedicine = "Rheumatology".localized(key: "health.speciality.medicine.rheumatologyMedicine")
                static let urologyMedicine = "Urology".localized(key: "health.speciality.medicine.urologyMedicine")
            }
         
            struct Odontology {
                static let generalOdontology = "General Odontology".localized(key: "health.speciality.odontology.generalOdontology")
                static let academicOdontology = "Academic Odontology".localized(key: "health.speciality.odontology.academicOdontology")
                static let paediatricOdontology = "Paediatric Odontology".localized(key: "health.speciality.odontology.paediatricOdontology")
                static let endodontics = "Endodontics".localized(key: "health.speciality.odontology.endodontics")
                static let orthodontics = "Orthodontics".localized(key: "health.speciality.odontology.orthodontics")
                static let prosthodontics = "Prosthodontics".localized(key: "health.speciality.odontology.prosthodontics")
                static let periodontics = "Periodontics".localized(key: "health.speciality.odontology.periodontics")
                static let maxillofacialSurgery = "Maxillofacial and Oral Surgery".localized(key: "health.speciality.odontology.maxillofacialSurgery")
                static let maxillofacialRadiology = "Maxillofacial and Oral Radiology".localized(key: "health.speciality.odontology.maxillofacialRadiology")
                static let oralPathology = "Oral and Maxillofacial Pathology".localized(key: "health.speciality.odontology.oralPathology")
                static let prothesis = "Dental Prothesis".localized(key: "health.speciality.odontology.prothesis")
                static let aesthetics = "Dental Aesthetics".localized(key: "health.speciality.odontology.aesthetics")
            }
            
            struct Pharmacy {
                static let generalPharmacy = "General Pharmacy".localized(key: "health.speciality.pharmacy.generalPharmacy")
                static let academicPharmacy = "Academic Pharmacy".localized(key: "health.speciality.pharmacy.academicPharmacy")
                static let ambulatoriPharmacy = "Ambulatory Care Pharmacy".localized(key: "health.speciality.pharmacy.ambulatoriPharmacy")
                static let cardiologyPharmacy = "Cardiology Pharmacy".localized(key: "health.speciality.pharmacy.cardiologyPharmacy")
                static let compoundedPharmacy = "Compounded Sterile Preparations Pharmacy".localized(key: "health.speciality.pharmacy.compoundedPharmacy")
                static let criticalPharmacy = "Critical Care Pharmacy".localized(key: "health.speciality.pharmacy.criticalPharmacy")
                static let emergencyPharmacy = "Emergency Medicine Pharmacy".localized(key: "health.speciality.pharmacy.emergencyPharmacy")
                static let geriatricPharmacy = "Geriatric Pharmacy".localized(key: "health.speciality.pharmacy.geriatricPharmacy")
                static let infectiousPharmacy = "Infectious Diseases Pharmacy".localized(key: "health.speciality.pharmacy.infectiousPharmacy")
                static let nuclearPharmacy = "Nuclear Pharmacy".localized(key: "health.speciality.pharmacy.nuclearPharmacy")
                static let nutritionPharmacy = "Nutrition Support Pharmacy".localized(key: "health.speciality.pharmacy.nutritionPharmacy")
                static let oncologyPharmacy = "Oncology Pharmacy".localized(key: "health.speciality.pharmacy.oncologyPharmacy")
                static let pediatricPharmacy = "Pediatric Pharmacy".localized(key: "health.speciality.pharmacy.pediatricPharmacy")
                static let pharmacotherapy = "Pharmacotherapy".localized(key: "health.speciality.pharmacy.pharmacotherapy")
                static let psychiatricPharmacy = "Psychiatric Pharmacy".localized(key: "health.speciality.pharmacy.psychiatricPharmacy")
                static let organPharmacy = "Solid Organ Transplantation Pharmacy".localized(key: "health.speciality.pharmacy.organPharmacy")
            }
            
            struct Physiotherapy {
                static let generalPhysiotherapy = "General Physiotherapy".localized(key: "health.speciality.physiotherapy.generalPhysiotherapy")
                static let academicPhysiotherapy = "Academic Physiotherapy".localized(key: "health.speciality.physiotherapy.academicPhysiotherapy")
                static let geriatricPhysiotherapy = "Geriatric".localized(key: "health.speciality.physiotherapy.geriatricPhysiotherapy")
                static let orthopaedicPhysiotherapy = "Orthopaedic".localized(key: "health.speciality.physiotherapy.orthopaedicPhysiotherapy")
                static let neurologyPhysiotherapy = "Neurology".localized(key: "health.speciality.physiotherapy.neurologyPhysiotherapy")
                static let pediatricPhysiotherapy = "Pediatric".localized(key: "health.speciality.physiotherapy.pediatricPhysiotherapy")
                static let oncologyPhysiotherapy = "Oncology".localized(key: "health.speciality.physiotherapy.oncologyPhysiotherapy")
                static let womensPhysiotherapy = "Women’s Health".localized(key: "health.speciality.physiotherapy.womensPhysiotherapy")
                static let electrophysiologicPhysiotherapy = "Electrophysiologic".localized(key: "health.speciality.physiotherapy.electrophysiologicPhysiotherapy")
                static let sportsPhysiotherapy = "Sports".localized(key: "health.speciality.physiotherapy.sportsPhysiotherapy")
                static let woundPhysiotherapy = "Wound Management".localized(key: "health.speciality.physiotherapy.woundPhysiotherapy")
            }
            
            struct Nursing {
                static let generalNurse = "General Nurse".localized(key: "health.speciality.nurse.generalNurse")
                static let cardiacNurse = "Cardiac Nurse".localized(key: "health.speciality.nurse.cardiacNurse")
                static let certifiedNurse = "Certified Registered Nurse Anesthetist".localized(key: "health.speciality.nurse.certifiedNurse")
                static let clinicalNurse = "Clinical Nurse Specialist".localized(key: "health.speciality.nurse.clinicalNurse")
                static let criticalNurse = "Critical Care Nurse".localized(key: "health.speciality.nurse.criticalNurse")
                static let geriatricNurse = "Geriatric Nursing".localized(key: "health.speciality.nurse.geriatricNurse")
                static let perioperativeNurse = "Perioperative Nurse".localized(key: "health.speciality.nurse.perioperativeNurse")
                static let mentalNurse = "Mental Health Nurse".localized(key: "health.speciality.nurse.mentalNurse")
                static let educatorNurse = "Nurse Educator".localized(key: "health.speciality.nurse.educatorNurse")
                static let midwifeNurse = "Nurse Midwife".localized(key: "health.speciality.nurse.midwifeNurse")
                static let oncologyNurse = "Oncology Nurse".localized(key: "health.speciality.nurse.oncologyNurse")
                static let pediatricNurse = "Pediatric Nurse".localized(key: "health.speciality.nurse.pediatricNurse")
                static let publicNurse = "Public Health Nurse".localized(key: "health.speciality.nurse.publicNurse")
            }
            
            struct Veterinary {
                static let generalVeterinary = "General Veterinary".localized(key: "health.speciality.veterinary.generalVeterinary")
                static let academicVeterinary = "Academic Veterinary".localized(key: "health.speciality.veterinary.academicVeterinary")
                static let animalWelfare = "Animal Welfare".localized(key: "health.speciality.veterinary.animalWelfare")
                static let behavioralVeterinary = "Behavioral Medicine".localized(key: "health.speciality.veterinary.behavioralVeterinary")
                static let pharmacologyVeterinary = "Clinical Pharmacology".localized(key: "health.speciality.veterinary.pharmacologyVeterinary")
                static let dentistryVeterinary = "Dentistry".localized(key: "health.speciality.veterinary.dentistryVeterinary")
                static let dermatologyVeterinary = "Dermatology".localized(key: "health.speciality.veterinary.dermatologyVeterinary")
                static let emergencyVeterinary = "Emergency and Critical Care".localized(key: "health.speciality.veterinary.emergencyVeterinary")
                static let internalVeterinary = "Internal Medicine".localized(key: "health.speciality.veterinary.internalVeterinary")
                static let laboratoryVeterinary = "Laboratory Animal Medicine".localized(key: "health.speciality.veterinary.laboratoryVeterinary")
                static let microbiologyVeterinary = "Microbiology".localized(key: "health.speciality.veterinary.microbiologyVeterinary")
                static let nutritionVeterinary = "Nutrition".localized(key: "health.speciality.veterinary.nutritionVeterinary")
                static let ophthalmologyVeterinary = "Ophthalmology".localized(key: "health.speciality.veterinary.ophthalmologyVeterinary")
                static let pathologyVeterinary = "Pathology".localized(key: "health.speciality.veterinary.pathologyVeterinary")
                static let poultryVeterinary = "Poultry Veterinary Medicine".localized(key: "health.speciality.veterinary.poultryVeterinary")
                static let preventiveVeterinary = "Preventive Medicine".localized(key: "health.speciality.veterinary.preventiveVeterinary")
                static let radiologyVeterinary = "Radiology".localized(key: "health.speciality.veterinary.radiologyVeterinary")
                static let speciesVeterinary = "Species-specialized Veterinary Practice".localized(key: "health.speciality.veterinary.rheumatologyVeterinary")
                static let sportsVeterinary = "Sports Medicine and Rehabilitation".localized(key: "health.speciality.veterinary.urologyVeterinary")
                static let surgeryVeterinary = "Surgery".localized(key: "health.speciality.veterinary.generalVeterinary")
                static let toxicologyVeterinary = "Toxicology".localized(key: "health.speciality.veterinary.academicVeterinary")
                static let zoologicalVeterinary = "Zoological Medicine".localized(key: "health.speciality.veterinary.animalWelfare")
            }

            
            struct Psychology {
                static let generalPsychology = "General Psychology".localized(key: "health.speciality.psychology.generalPsychology")
                static let academicPsychology = "Academic Psychology".localized(key: "health.speciality.psychology.academicPsychology")
                static let neuropsychology = "Clinical Neuropsychology".localized(key: "health.speciality.psychology.neuropsychology")
                static let healthPsychology = "Clinical Health Psychology".localized(key: "health.speciality.psychology.healthPsychology")
                static let psychoanalysis = "Psychoanalysis".localized(key: "health.speciality.psychology.psychoanalysis")
                static let schoolPsychology = "School Psychology".localized(key: "health.speciality.psychology.schoolPsychology")
                static let clinicalPsychology = "Clinical Psychology".localized(key: "health.speciality.psychology.clinicalPsychology")
                static let childPsychology = "Clinical Child and Adolescent Psychology".localized(key: "health.speciality.psychology.childPsychology")
                static let counselingPsychology = "Counseling Psychology".localized(key: "health.speciality.psychology.counselingPsychology")
                static let industrialPsychology = "Industrial-Organizational Psychology".localized(key: "health.speciality.psychology.industrialPsychology")
                static let behavioralPsychology = "Behavioral and Cognitive Psychology".localized(key: "health.speciality.psychology.behavioralPsychology")
                static let forensicPsychology = "Forensic Psychology".localized(key: "health.speciality.psychology.forensicPsychology")
                static let familyPsychology = "Couple and Family Psychology".localized(key: "health.speciality.psychology.familyPsychology")
                static let geropsychology = "Geropsychology".localized(key: "health.speciality.psychology.geropsychology")
                static let policePsychology = "Police and Public Safety Psychology".localized(key: "health.speciality.psychology.policePsychology")
                static let sleepPsychology = "Sleep Psychology".localized(key: "health.speciality.psychology.sleepPsychology")
                static let rehabilitationPsychology = "Rehabilitation Psychology".localized(key: "health.speciality.psychology.rehabilitationPsychology")
                static let clinicalPsychopharmacology = "Clinical Psychopharmacology".localized(key: "health.speciality.psychology.clinicalPsychopharmacology")
                static let addictionPsychology = "Addiction Psychology".localized(key: "health.speciality.psychology.addictionPsychology")
                static let sportPsychology = "Sport Psychology".localized(key: "health.speciality.psychology.sportPsychology")
            }
            
            struct Podiatry {
                static let generalPodiatry = "General Podiatry".localized(key: "health.speciality.podiatry.generalPodiatry")
                static let academicPodiatry = "Academic Podiatry".localized(key: "health.speciality.podiatry.academicPodiatry")
                static let reconstructivePodiatry = "Reconstructive Surgery".localized(key: "health.speciality.podiatry.reconstructivePodiatry")
                static let medicinePodiatry = "Podiatric Medicine".localized(key: "health.speciality.podiatry.medicinePodiatry")
                static let orthopedicsPodiatry = "Podiatric Orthopedics".localized(key: "health.speciality.podiatry.orthopedicsPodiatry")
                static let sportsPodiatry = "Podiatric Sports Medicine".localized(key: "health.speciality.podiatry.sportsPodiatry")
                static let riskPodiatry = "High-risk Wound Care".localized(key: "health.speciality.podiatry.riskPodiatry")
                static let rheumatologyPodiatry = "Podiatric Rheumatology".localized(key: "health.speciality.podiatry.rheumatologyPodiatry")
                static let neuropodiatry = "Neuropodiatry".localized(key: "health.speciality.podiatry.neuropodiatry")
                static let oncopodiatry = "Oncopodiatry".localized(key: "health.speciality.podiatry.oncopodiatry")
                static let vascularPodiatry = "Podiatric Vascular Medicine".localized(key: "health.speciality.podiatry.vascularPodiatry")
                static let dermatologyPodiatry = "Podiatric Dermatology".localized(key: "health.speciality.podiatry.dermatologyPodiatry")
                static let podoradiology = "Podoradiology".localized(key: "health.speciality.podiatry.podoradiology")
                static let gerontologyPodiatry = "Podiatric Gerontology".localized(key: "health.speciality.podiatry.gerontologyPodiatry")
                static let diabetologyPodiatry = "Podiatric Diabetology".localized(key: "health.speciality.podiatry.diabetologyPodiatry")
                static let podopediatrics = "Podopediatrics".localized(key: "health.speciality.podiatry.podopediatrics")
                static let forensicPodiatry = "Forensic Podiatry".localized(key: "health.speciality.podiatry.forensicPodiatry")
            }
            
            struct Nutrition {
                static let generalNutrition = "General Nutrition & Dietetics".localized(key: "health.speciality.nutrition.generalNutrition")
                static let academicNutrition = "Academic Nutrition & Dietetics".localized(key: "health.speciality.nutrition.academicNutrition")
                static let clinicalNutrition = "Clinical Nutrition".localized(key: "health.speciality.nutrition.clinicalNutrition")
                static let communityNutrition = "Community Nutrition".localized(key: "health.speciality.nutrition.communityNutrition")
                static let proceduralExpertise = "Procedural Expertise".localized(key: "health.speciality.nutrition.proceduralExpertise")
                static let sportsNutrition = "Sports Nutritionist".localized(key: "health.speciality.nutrition.sportsNutrition")
                static let pediatricNutrition = "Pediatric Nutritionist".localized(key: "health.speciality.nutrition.pediatricNutrition")
                static let gerontologicalNutrition = "Gerontological Nutritionist".localized(key: "health.speciality.nutrition.gerontologicalNutrition")
                static let renalNutrition = "Renal or Nephrology Nutritionist".localized(key: "health.speciality.nutrition.renalNutrition")
            }
            
            struct Optics {
                static let generalOptics = "General Optics & Optometry".localized(key: "health.speciality.optics.generalOptics")
                static let academicOptics = "Academic Optics & Optometry".localized(key: "health.speciality.optics.academicOptics")
                static let corneaContactLenses = "Cornea and Contact Lenses".localized(key: "health.speciality.optics.corneaContactLenses")
                static let ocularDisease = "Ocular Disease".localized(key: "health.speciality.optics.ocularDisease")
                static let opticsLowVision = "Low Vision".localized(key: "health.speciality.optics.opticsLowVision")
                static let opticsPediatrics = "Pediatrics".localized(key: "health.speciality.optics.opticsPediatrics")
                static let opticsGeriatrics = "Geriatrics".localized(key: "health.speciality.optics.opticsGeriatrics")
                static let opticsOptometry = "Neuro-Optometry".localized(key: "health.speciality.optics.opticsOptometry")
                static let opticsVisionTherapy = "Behavioral Optometry and Vision Therapy".localized(key: "health.speciality.optics.opticsVisionTherapy")
            }
            
            struct Biomedical {
                static let generalBiomedical = "General Biomedical Science".localized(key: "health.speciality.biomedical.generalBiomedical")
                static let academicBiomedical = "Academic Biomedical Science".localized(key: "health.speciality.biomedical.academicBiomedical")
                static let engineeringBiomechanical = "Biomechanical Engineering".localized(key: "health.speciality.biomedical.engineeringBiomechanical")
                static let engineeringBiomedical = "Biomedical Engineering".localized(key: "health.speciality.biomedical.engineeringBiomedical")
                static let clinicalBiochemistry = "Clinical Biochemistry".localized(key: "health.speciality.biomedical.clinicalBiochemistry")
                static let clinicalEngineering = "Clinical Engineering".localized(key: "health.speciality.biomedical.clinicalEngineering")
                static let medicalElectronics = "Medical Electronics".localized(key: "health.speciality.biomedical.medicalElectronics")
                static let microbiology = "Microbiology".localized(key: "health.speciality.biomedical.microbiology")
            }
            
            struct Physical {
                static let generalSports = "General Sports and Science".localized(key: "health.speciality.physical.generalSports")
                static let academicSports = "Academic Physical Sports and Science".localized(key: "health.speciality.physical.academicSports")
                static let managementSports = "Sports Management".localized(key: "health.speciality.physical.managementSports")
                static let trainingSports = "Training and Sports Performance".localized(key: "health.speciality.physical.trainingSports")
                static let healthSports = "Health and Quality of Life".localized(key: "health.speciality.physical.healthSports")
                static let recreationSports = "Sports Recreation and Leisure".localized(key: "health.speciality.physical.recreationSports")
            }
            
            struct Speech {
                static let generalSpeech = "General Speech Therapy".localized(key: "health.speciality.speech.generalSpeech")
                static let academicSpeech = "Academic Speech Therapy".localized(key: "health.speciality.speech.academicSpeech")
                static let articulationSpeech = "Articulation and Phonology".localized(key: "health.speciality.speech.articulationSpeech")
                static let languageSpeech = "Language Development".localized(key: "health.speciality.speech.languageSpeech")
                static let oralSpeech = "Oral Motor and Swallowing Dysfunction".localized(key: "health.speciality.speech.oralSpeech")
                static let sensorSpeech = "Sensory Integration".localized(key: "health.speciality.speech.sensorSpeech")
                static let autismSpeech = "Autism Spectrum".localized(key: "health.speciality.speech.autismSpeech")
                static let augmentativeSpeech = "Augmentative Communication".localized(key: "health.speciality.speech.augmentativeSpeech")
            }
            
            struct Occupational {
                static let generalTherapy = "General Occupational Therapy".localized(key: "health.speciality.occupational.generalTherapy")
                static let academicTherapy = "Academic Occupational Therapy".localized(key: "health.speciality.occupational.academicTherapy")
                static let gerontologyTherapy = "Gerontology".localized(key: "health.speciality.occupational.gerontologyTherapy")
                static let mentalTherapy = "Mental Health".localized(key: "health.speciality.occupational.mentalTherapy")
                static let pediatricsTherapy = "Pediatrics".localized(key: "health.speciality.occupational.pediatricsTherapy")
                static let physicalTherapy = "Physical Rehabilitation".localized(key: "health.speciality.occupational.physicalTherapy")
                static let drivingTherapy = "Driving and Community Mobility".localized(key: "health.speciality.occupational.drivingTherapy")
                static let lowVisionTherapy = "Low Vision".localized(key: "health.speciality.occupational.lowVisionTherapy")
                static let schoolTherapy = "School Systems".localized(key: "health.speciality.occupational.schoolTherapy")
            }
        }
    }
}
