//
//  SolidSignIn.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import ServerShared
import iOSSignIn
import iOSShared
import PersistentValue
import UIKit
import SolidAuthSwiftUI

public class SolidSignIn : NSObject, GenericSignIn {    
    public var signInName: String = "Solid"
    
    fileprivate var stickySignIn = false
    
    fileprivate let signInOutButton = SolidSignInOutButton()
    
    weak public var delegate:GenericSignInDelegate?
    
    fileprivate var autoSignIn = true
    
    static private let credentialsData = try! PersistentValue<Data>(name: "SolidSignIn.data", storage: .keyChain)
    var controller: SignInController!
    let config:SignInConfiguration
    
    public init(config:SolidSignInConfig) {
        self.config = SignInConfiguration(
            issuer: config.issuer,
            redirectURI: config.redirectURI,
            clientName: config.clientName,
            scopes: [.openid, .profile, .webid, .offlineAccess],
            responseTypes:  [.code, .idToken])
        
        super.init()
        signInOutButton.delegate = self
    }

    static var savedCreds:SolidSavedCreds? {
        set {
            let data = try? newValue?.toData()
#if DEBUG
            if let data = data {
                if let string = String(data: data, encoding: .utf8) {
                    iOSShared.logger.debug("savedCreds: \(string)")
                }
            }
#endif
            Self.credentialsData.value = data
        }
        
        get {
            guard let data = Self.credentialsData.value,
                let savedCreds = try? SolidSavedCreds.fromData(data) else {
                return nil
            }
            return savedCreds
        }
    }

    public var credentials:GenericCredentials? {
        if let savedCreds = Self.savedCreds {
            return SolidCredentials(savedCreds: savedCreds)
        }
        else {
            return nil
        }
    }
    
    public let userType:UserType = .owning
    public let cloudStorageType: CloudStorageType? = .Solid
    
    public func appLaunchSetup(userSignedIn: Bool, withLaunchOptions options:[UIApplication.LaunchOptionsKey : Any]?) {
    
        stickySignIn = userSignedIn
        autoSignIn = userSignedIn
                
        if userSignedIn {
            // I'm not sure if this is ever going to happen-- that we have non-nil creds on launch.
            if let creds = credentials {
                self.userSignedIn(autoSignIn: true, credentials: creds)
            }
            else {
                signUserOut(message: "No creds but userSignedIn == true")
            }
        }
        else {
            signUserOut(message: "userSignedIn == false")
        }
    }
    
    func userSignedIn(autoSignIn: Bool, credentials: GenericCredentials) {
        self.autoSignIn = autoSignIn
        stickySignIn = true
        signInOutButton.buttonShowing = .signOut
        delegate?.haveCredentials(self, credentials: credentials)
        delegate?.signInCompleted(self, autoSignIn: autoSignIn)
    }
    
    public func networkChangedState(networkIsOnline: Bool) {
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return false
    }
    
    public var userIsSignedIn: Bool {
        return stickySignIn
    }

    public func signInButton(configuration: [String : Any]?) -> UIView? {
        return signInOutButton
    }
}

// MARK: UserSignIn methods.
extension SolidSignIn {
    @objc public func signUserOut() {
        signUserOut(message: nil)
    }
    
    @objc public func signUserOut(message: String? = nil) {
        iOSShared.logger.error("signUserOut: \(String(describing: message))")
        stickySignIn = false
        
        Self.savedCreds = nil
        
        signInOutButton.buttonShowing = .signIn
        delegate?.userIsSignedOut(self)
    }
}

extension SolidSignIn: SolidSignInOutButtonDelegate {
    func signUserIn(_ button: SolidSignInOutButton) {
        delegate?.signInStarted(self)
        
        do {
            controller = try SignInController(config: config)
        }
        catch let error {
            delegate?.signInCancelled(self)
            iOSShared.logger.error("Could not initialize Controller: \(error)")
            return
        }
        
        controller.start { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let idToken = response.authResponse.idToken else {
                    iOSShared.logger.error("Could not get id token from controller response")
                    self.delegate?.signInCancelled(self)
                    return
                }
                
                Self.savedCreds = SolidSavedCreds(parameters: response.parameters, idToken: idToken)
                self.delegate?.signInCompleted(self, autoSignIn: self.autoSignIn)

            case .failure(let error):
                iOSShared.logger.error("Could not start Controller: \(error)")
                self.delegate?.signInCancelled(self)
            }
        }
    }
    
    func signUserOut(_ button: SolidSignInOutButton) {
        signUserOut()
    }
}