//
//  SolidSignInConfig.swift
//  
//
//  Created by Christopher G Prince on 7/30/21.
//

import Foundation

public struct SolidSignInConfig {
    // e.g., "https://solidcommunity.net"
    public let issuer: String
    
    // E.g., "biz.SpasticMuffin.Neebla.demo:/mypath"
    public let redirectURI: String

    // It looks like this should up in the sign in UI for the Pod. But not seeing it yet when using solidcommunity.net.
    public let clientName: String
    
    public init(issuer: String, redirectURI: String, clientName: String) {
        self.issuer = issuer
        self.redirectURI = redirectURI
        self.clientName = clientName
    }
}