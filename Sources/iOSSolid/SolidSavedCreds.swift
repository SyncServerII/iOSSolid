//
//  SolidSavedCreds.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import iOSSignIn
import SolidAuthSwiftTools

public class SolidSavedCreds: GenericCredentialsCodable {
    public var emailAddress: String! {
        return email
    }
    
    // We don't get this on the client for Solid; get it on the server
    public var userId:String = ""

    // Unused. Just for compliance to `GenericCredentialsCodable`.
    public var uiDisplayName:String?

    public var username:String?
    public var email:String?
    let parameters: ServerParameters
    let idToken: String
    
    public init(parameters: ServerParameters, idToken: String, email: String?, username: String?) {
        self.parameters = parameters
        self.idToken = idToken
        self.email = email
        self.username = username
    }
}
