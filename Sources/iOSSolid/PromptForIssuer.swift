//
//  PromptForIssuer.swift
//  
//
//  Created by Christopher G Prince on 7/31/21.
//

import Foundation
import UIKit

// I'm using UIKit for this because it seems simpler than adapting iOSSignIn just to have it be able to add an initial, sign in specific, prompt.

class PromptForIssuer {
    enum Result {
        case cancelled
        case error(String)
        case success(URL)
    }
    
    func present(on viewController: UIViewController, completion: @escaping (Result)->()) {
        let alertController = UIAlertController(title: "Enter Pod Issuer URL", message: "Please enter the issuer URL for your Solid Pod (e.g., https://solidcommunity.net)", preferredStyle: .alert)
        alertController.addTextField()
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
            
            completion(.success(url))
        }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
