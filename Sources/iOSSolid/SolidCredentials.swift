//
//  SolidCredentials.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import iOSSignIn
import ServerShared
import iOSShared
import SolidAuthSwiftTools

public class SolidCredentials : GenericCredentials, CustomDebugStringConvertible {
    public var emailAddress: String! {
        return savedCreds.email
    }
    
    var savedCreds:SolidSavedCreds!

    public var userId:String {
        return savedCreds.userId
    }
    
    public var username:String? {
        return savedCreds.username
    }
    
    public var uiDisplayName:String? {
        return savedCreds.email ?? savedCreds.username
    }
    
    public var email:String? {
        return savedCreds.email
    }
    
    // Helper
    public init(savedCreds:SolidSavedCreds) {
        self.savedCreds = savedCreds
    }

    public var httpRequestHeaders:[String:String] {
        var result = [String:String]()
        result[ServerConstants.XTokenTypeKey] = AuthTokenType.SolidToken.rawValue
        
        do {
            result[ServerConstants.HTTPAccountDetailsKey] = try savedCreds.parameters.toBase64()
        } catch let error {
            iOSShared.logger.error("Could not encode parameters into data for Solid creds: \(error)")
        }
        
        result[ServerConstants.HTTPIdTokenKey] = self.savedCreds.idToken
        
        // This is required because the users webid is used as a unique account name for Solid accounts on SyncServer.
        result[ServerConstants.HTTPAccountIdKey] = self.savedCreds.parameters.webid
        
        iOSShared.logger.debug("httpRequestHeaders: \(result)")
        
        return result
    }
        
    open func refreshCredentials(completion: @escaping (Swift.Error?) ->()) {
        // Token refresh only takes place on server with Solid as it requires a key pair.
        completion(GenericCredentialsError.noRefreshAvailable)
    }
    
    public var debugDescription: String {
        return "\(String(describing: savedCreds))"
    }
}
