//
//  PromptForStorage.swift
//  
//
//  Created by Christopher G Prince on 9/12/21.
//

import Foundation
import UIKit
import SwiftUI
import iOSShared

class PromptForStorage {
    func present(on viewController: UIViewController, defaultStorageIRI: URL?, completion: @escaping (Result<Storage, Error>)->()) {
    
        let model = StorageIRIModel(defaultStorageIRI: defaultStorageIRI, completion: completion)
        let hostingController = Host(rootView: StorageIRIView(model: model))
        
        model.dismissable = hostingController
        hostingController.model = model
        
        viewController.present(hostingController, animated: true, completion: nil)
    }
}

protocol Dimissable: AnyObject {
    func dismiss(completion:(()->())?)
}

class Host<Content> : UIHostingController<Content>, Dimissable where Content : View {
    var model:StorageIRIModel!

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        model?.checkIfCompletionCalled()
    }
    
    // MARK: Dimissable
    
    func dismiss(completion:(()->())?) {
        dismiss(animated: true, completion: completion)
    }
}
