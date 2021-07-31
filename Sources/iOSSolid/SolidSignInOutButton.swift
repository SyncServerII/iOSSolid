
import Foundation
import UIKit
import iOSShared

protocol SolidSignInOutButtonDelegate: AnyObject {
    func signUserIn(_ button: SolidSignInOutButton)
    func signUserOut(_ button: SolidSignInOutButton)
}

class SolidSignInOutButton : UIView {
    // Subviews: `signInOutContentView` and `signInOutButton`
    let signInOutContainer = UIView()
    
    // Subviews: `iconView` and `signInOutLabel`.
    let signInOutContentView = UIView()
    
    let signInOutButton = UIButton(type: .system)
    
    let signInOutLabel = UILabel()
    var iconView:UIImageView!
    
    let signInText = "Sign into a Solid Pod"
    let signOutText = "Sign out"
    
    weak var delegate: SolidSignInOutButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        signInOutButton.addTarget(self, action: #selector(signInOutButtonAction), for: .touchUpInside)
        addSubview(signInOutContainer)
        
        signInOutContainer.addSubview(signInOutContentView)
        signInOutContainer.addSubview(signInOutButton)

        let imageURL = Bundle.module.bundleURL.appendingPathComponent("Images/SolidIcon-100x100.png")
        let iconImage = UIImage(contentsOfFile: imageURL.path)
        iconView = UIImageView(image: iconImage)
        iconView.contentMode = .scaleAspectFit
        signInOutContentView.addSubview(iconView)
        
        signInOutLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        signInOutContentView.addSubview(signInOutLabel)

        let layer = signInOutButton.layer
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        
        self.buttonShowing = .signIn
    }
    
    @objc func signInOutButtonAction() {
        iOSShared.logger.debug("signInOutButtonAction")
        switch buttonShowing {
        case .signIn:
            delegate?.signUserIn(self)

        case .signOut:
            delegate?.signUserOut(self)
        }
    }
    
    func layout(with frame: CGRect) {
        signInOutContainer.frame.size = frame.size
        signInOutContentView.frame.size = frame.size
        signInOutButton.frame.size = frame.size
        
        let margin:CGFloat = 20
        var sizeReducedByMargins = frame.size
        sizeReducedByMargins.height -= margin
        sizeReducedByMargins.width -= margin
        signInOutContentView.frame.size = sizeReducedByMargins
        signInOutContentView.frame.origin = CGPoint(x: margin*0.5, y: margin*0.5)
        
        let iconSize = frame.size.height * 0.6
        iconView.frame.size = CGSize(width: iconSize, height: iconSize)
        iconView.frame.origin = CGPoint.zero
        iconView.centerVerticallyInSuperview()

        signInOutLabel.frame.origin.x = iconSize * 1.7
        signInOutLabel.centerVerticallyInSuperview()
        
        switch traitCollection.userInterfaceStyle {
        case .dark:
            signInOutContainer.backgroundColor = UIColor.darkGray
        case .light, .unspecified:
            signInOutContainer.backgroundColor = UIColor.white
        @unknown default:
            signInOutContainer.backgroundColor = UIColor.white
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout(with: frame)
    }
    
    enum State {
        case signIn
        case signOut
    }

    fileprivate var _state:State = .signIn
    var buttonShowing:State {
        get {
            return self._state
        }
        
        set {
            iOSShared.logger.debug("Change sign-in state: \(newValue)")
            
            DispatchQueue.main.async {
                self._state = newValue
                switch self._state {
                case .signIn:
                    self.signInOutLabel.text = self.signInText
                
                case .signOut:
                    self.signInOutLabel.text = self.signOutText
                }
                
                self.signInOutLabel.sizeToFit()
                
                self.setNeedsDisplay()
            }
        }
    }
}

