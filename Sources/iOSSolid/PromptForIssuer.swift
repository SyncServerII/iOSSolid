//
//  PromptForIssuer.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import UIKit

// I'm using UIKit for this because it seems simpler than adapting iOSSignIn just to have it be able to add an initial, sign in specific, prompt.

class PromptForUserDetails {
    enum Result {
        struct UserDetails {
            let issuer: URL
            let email: String?
            let username: String?
        }
        
        case cancelled
        case error(String)
        case success(UserDetails)
    }
    
    func present(on viewController: UIViewController, completion: @escaping (Result)->()) {
        let alertController = UIAlertController(title: "Provide Some Details", message: "The issuer URL for your Solid Pod (e.g., https://solidcommunity.net) is required in order for you to sign in. Your email address we would only use if providing necessary system support. Your name would just be used to improve your user experience.", preferredStyle: .alert)
        alertController.addTextField() { textField in
            textField.placeholder = "Pod issuer URL (required)"
        }
        alertController.addTextField() { textField in
            textField.placeholder = "Your email (suggested)"
        }
        alertController.addTextField() { textField in
            textField.placeholder = "Your name (suggested)"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(.cancelled)
        }))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            guard let issuer = alertController.textFields?[0].text else {
                completion(.error("No text entered for issuer"))
                return
            }
            
            guard let url = URL(string: issuer) else {
                completion(.error("Could not get URL for issuer."))
                return
            }
            
            let email = alertController.textFields?[1].text
            let username = alertController.textFields?[2].text
            
            let result = Result.UserDetails(issuer: url, email: email, username: username)
            
            completion(.success(result))
        }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
