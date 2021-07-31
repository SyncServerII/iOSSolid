//
//  SolidSignInDelegate.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import UIKit

public protocol SolidSignInDelegate: AnyObject {
    // Need the current view controller to present an initial `issuer` URL prompt.
    func getCurrentViewController() -> UIViewController?
}
