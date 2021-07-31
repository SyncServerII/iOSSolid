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
    
    // We don't get this on the client for Solid; needs key pair on the server
    public var userId:String = ""

    // Unused. Just for compliance to `GenericCredentialsCodable`.
    public var username:String?
    public var uiDisplayName:String?
    public var email:String?
    
    let parameters: CodeParameters
    let idToken: String
    
    public init(parameters: CodeParameters, idToken: String) {
        self.parameters = parameters
        self.idToken = idToken
    }
}
