//
//  Extensions.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import AVKit
import Firebase

fileprivate var containerView: UIView!

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
           assert(red >= 0 && red <= 255, "Invalid red component")
           assert(green >= 0 && green <= 255, "Invalid green component")
           assert(blue >= 0 && blue <= 255, "Invalid blue component")

           self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
       }

       convenience init(rgb: Int) {
           self.init(
               red: (rgb >> 16) & 0xFF,
               green: (rgb >> 8) & 0xFF,
               blue: rgb & 0xFF
           )
       }
}

extension UIView {
    
    func activityStartAnimating() {
        let backgroundView = UIView()
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)
        self.addSubview(backgroundView)
    }
    
    func activityStopAnimating() {
            if let background = viewWithTag(475647){
                background.removeFromSuperview()
            }
            self.isUserInteractionEnabled = true
    }
}

extension UIViewController {
    
    func displayAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMEDestructiveAlert(withTitle title: String, withMessage message: String, withCancelButtonText cancelButtonText: String, withDoneButtonText doneButtonText: String, completion: @escaping() -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: cancelButtonText, style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: doneButtonText, style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func dismissDiagnosisAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Skip diagnosis", message: "Are you sure you want to solve this case without adding a diagnosis?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Skip", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteConversationAlert(completion: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Conversation", message: "This conversation will be deleted from your inbox. Other pople in the conversation will still be able to see it.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            completion(false)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            completion(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func logoutAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out of MyEvidens?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log out", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func unfollowAlert(withUserFirstName name: String, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Unfollow \(name)", message: "Are you sure you want to unfollow \(name)?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Unfollow", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deletePostAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Delete post", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteCommentAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Delete comment", message: "Are you sure you want to delete this comment?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reportPostAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Report post", message: "Are you sure you want to report this post to our moderation team?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reportCommentAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Report comment", message: "Are you sure you want to report this comment to our moderation team?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reportCaseAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Report case", message: "Are you sure you want to report this case to our moderation team?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteRecentSearchesAlert(completion: @escaping() -> Void) {
        let alert = UIAlertController(title: "Clear search history?", message: "Are you sure you want to clear your search results history?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .white
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            containerView.removeFromSuperview()
            containerView = nil
        }
    }
}

extension UIView {
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    func pushTransitionDown(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
}

extension Date {

    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, from date: Date) -> Float {
        let currentCalendar = Calendar.current
        guard let startDate = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0.0 }
        
        guard let endDate = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0.0 }
        
        return Float(startDate - endDate)
    }
}

extension UIImage {
    
}


extension UIScrollView {
    
    func resizeScrollViewContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.contentSize = contentRect.size
        
    }
    
    func resizeScrollViewContentSize(_ height: CGFloat) {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        //self.contentSize = contentRect.size - CGSize(width: 0, height: height)
        self.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height - height)
        
    }
}


extension Array where Element: Equatable {
    func sortBy(orderArray: [Element]) -> [Element]? {

        // Index of each element in `orderArray`:
        let targetIndices = self.compactMap { orderArray.firstIndex(of: $0) }
        // Verify that each array element occurs in `orderArray`:
        guard targetIndices.count == self.count else {
            return nil
        }
        // Sort array indices according to their index in `orderArray`:
        let sortedIndices = self.indices.sorted { targetIndices[$0] < targetIndices[$1] }
        // Rearrange elements accordingly:
        return sortedIndices.map { self[$0] }
    }
}


extension UILabel {
    func countLines() -> Int {
      guard let myText = self.text as NSString? else {
        return 0
      }
      self.layoutIfNeeded()
      let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
      let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
      return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
    
    var maxNumberOfLines: Int {
            let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
            let text = (self.text ?? "") as NSString
            let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
            let lineHeight = font.lineHeight
            return Int(ceil(textHeight / lineHeight))
        }
    
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}

extension UIViewController {

    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */
    
    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }

    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

extension UIViewController {
    func changeBackgroundAlphaToDark(_ darker: Bool) {
        if let keyWindow = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
            keyWindow.alpha = darker ? 0.85 : 1
        }
    }
}

extension UIView {
    func setHeightConstraint(toConstant constant: CGFloat) {
        constraints.forEach {
            if $0.firstAttribute == .height {
                self.removeConstraint($0)
            }
        }
        heightAnchor.constraint(equalToConstant: constant).isActive = true
        layoutIfNeeded()
    }
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension UIViewController {
    func hideKeyboardOnViewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



// MARK: - Gradient
extension CAGradientLayer {
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
        self.init()
        self.startPoint = start.point
        self.endPoint = end.point
        self.colors = colors
        self.locations = (0..<colors.count).map(NSNumber.init)
        self.type = type
    }
}

extension UIView {

var heightConstraint: NSLayoutConstraint? {
    get {
        return constraints.first(where: {
            $0.firstAttribute == .height && $0.relation == .equal
        })
    }
    set { setNeedsLayout() }
}

var widthConstraint: NSLayoutConstraint? {
    get {
        return constraints.first(where: {
            $0.firstAttribute == .width && $0.relation == .equal
        })
    }
    set { setNeedsLayout() }
}

}




