//
//  StorageIRIModel.swift
//  
//
//  Created by Christopher G Prince on 9/12/21.
//

import Foundation

enum Storage {
    // Possibly user updated/entered storageIRI.
    case iri(URL)
    
    case cancelSignIn
}
    
class StorageIRIModel: ObservableObject {
    @Published var storageIRI: String?
    @Published var continueEnabled = false
    let completion: (Result<Storage, Error>)->()
    var completionCalled = false
    let defaultStorageIRI: URL?
    
    // To be returned in completion.
    var returnIRI: URL?
    
    weak var dismissable: Dimissable!
    
    // If non-nil, `defaultStorageIRI` will have the storage IRI obtained from the users profile, with a default folder appended.
    init(defaultStorageIRI: URL?, completion: @escaping (Result<Storage, Error>)->()) {
        self.storageIRI = defaultStorageIRI?.absoluteString
        self.completion = completion
        self.defaultStorageIRI = defaultStorageIRI
        
        if let defaultStorageIRI = defaultStorageIRI {
            continueEnabled = true
            returnIRI = defaultStorageIRI
        }
    }
    
    // The `storageIRI` has been updated.
    func updateStorageIRI() {
        guard let defaultStorageIRI = defaultStorageIRI else {
            guard var storageIRI = storageIRI else {
                continueEnabled = false
                return
            }

            storageIRI = storageIRI.trimmingCharacters(in: .whitespaces)
        
            guard let result = URL(string: storageIRI) else {
                continueEnabled = false
                return
            }
            
            continueEnabled = true
            returnIRI = result
            return
        }
        
        guard var storageIRI = storageIRI else {
            continueEnabled = false
            return
        }
        
        storageIRI = storageIRI.trimmingCharacters(in: .whitespaces)
        
        guard storageIRI.hasPrefix(defaultStorageIRI.absoluteString) else {
            continueEnabled = false
            return
        }
        
        guard let result = URL(string: storageIRI) else {
            continueEnabled = false
            return
        }
        
        returnIRI = result
        continueEnabled = true
    }
    
    func dismiss() {
        finish(storage: Storage.cancelSignIn)
    }
    
    func continueTapped() {
        guard let returnIRI = returnIRI else {
            continueEnabled = false
            return
        }
        
        finish(storage: Storage.iri(returnIRI))
    }
    
    func checkIfCompletionCalled() {
        guard !completionCalled else {
            return
        }
        
        completion(.success(Storage.cancelSignIn))
    }
    
    private func finish(storage: Storage) {
        completionCalled = true
        
        dismissable?.dismiss(completion: { [weak self] in
            guard let self = self else { return }
            self.completion(.success(storage))
        })
    }
}
