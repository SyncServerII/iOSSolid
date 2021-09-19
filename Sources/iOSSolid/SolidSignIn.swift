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
import SolidAuthSwiftTools

public class SolidSignIn : NSObject, GenericSignIn {    
    public var signInName: String = "Solid"
    
    fileprivate var stickySignIn = false
    
    fileprivate let signInOutButton = SolidSignInOutButton()
    
    weak public var delegate:GenericSignInDelegate?
    
    fileprivate var autoSignIn = true
    
    static private let credentialsData = try! PersistentValue<Data>(name: "SolidSignIn.data", storage: .keyChain)
    var controller: SignInController!
    let config:SolidSignInConfig
    var promptForUserDetails: PromptForUserDetails!
    var promptForStorage: PromptForStorage!
    weak var solidDelegate: SolidSignInDelegate?
    
    public init(config:SolidSignInConfig, delegate: SolidSignInDelegate) {
        solidDelegate = delegate
        self.config = config
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
        
        guard let vc = solidDelegate?.getCurrentViewController() else {
            delegate?.signInCancelled(self)
            iOSShared.logger.error("Could not get current view controller")
            return
        }

        promptForUserDetails = PromptForUserDetails()
        promptForUserDetails.present(on: vc) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .cancelled:
                self.delegate?.signInCancelled(self)
                
            case .error(let errorString):
                self.delegate?.signInCancelled(self)
                iOSShared.logger.error("Error getting issuer URL: \(errorString)")
                
            case .success(let userDetails):
                self.signInUsingController(userDetails: userDetails)
            }
        }
    }
    
    private func signInUsingController(userDetails: PromptForUserDetails.Result.UserDetails) {
        do {
            let signInConfiguration = SignInConfiguration(
                issuer: userDetails.issuer.absoluteString,
                redirectURI: self.config.redirectURI,
                clientName: self.config.clientName,
                scopes: [.openid, .profile, .webid, .offlineAccess],
                responseTypes:  [.code],
                grantTypes: [.authorizationCode, .refreshToken],
                authenticationMethod: .basic)
            
            controller = try SignInController(config: signInConfiguration)
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
                guard let vc = self.solidDelegate?.getCurrentViewController() else {
                    self.delegate?.signInCancelled(self)
                    iOSShared.logger.error("Could not get current view controller")
                    return
                }

                func finish(storageIRI: URL?) {
                    let params: ServerParameters
                    if let storageIRI = storageIRI {
                        params = ServerParameters(refresh: response.parameters.refresh, storageIRI: storageIRI, jwksURL: response.parameters.jwksURL)
                    }
                    else {
                        params = response.parameters
                    }
                    
                    Self.savedCreds = SolidSavedCreds(parameters: params, idToken: response.idToken, email: userDetails.email, username: userDetails.username)
                    self.delegate?.signInCompleted(self, autoSignIn: self.autoSignIn)
                }

                // Need to know if this is a (a) sign in of an existing user or (b) sign in of a new user. Only if it's a new user do we want to prompt for storage.

                switch self.delegate?.accountMode(self) {
                case .signIn:
                    finish(storageIRI: nil)
                    return
                case .acceptInvitation:
                    break
                case .createOwningUser:
                    break
                case .none:
                    break
                }
                
                let defaultStorageIRI = response.parameters.storageIRI?.appendingPathComponent(self.config.defaultCloudFolderName)
                
                self.promptForStorage = PromptForStorage()
                self.promptForStorage.present(on: vc, defaultStorageIRI: defaultStorageIRI) { result in
                    switch result {
                    case .success(let storage):
                        switch storage {
                        case .iri(let storageIRI):
                            finish(storageIRI: storageIRI)
                            
                        case .cancelSignIn:
                            self.delegate?.signInCancelled(self)
                        }
                        
                    case .failure(let error):
                        iOSShared.logger.error("Error in prompt for storage IRI: \(error)")
                        self.delegate?.signInCancelled(self)
                    }
                }

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
