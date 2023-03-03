//
//  ExampleAuthProvider.swift
//  Runner
//
//  Created by Adam Mihalik on 02/03/2023.
//

import Foundation
import ExponeaSDK

@objc(ExponeaAuthProvider)
public class ExampleAuthProvider: NSObject, AuthorizationProviderType {
    required public override init() { }
    public func getAuthorizationToken() -> String? {
        // Receive and return JWT token here.
        return CustomerTokenStorage.shared.retrieveJwtToken()
        // NULL as returned value will be handled by SDK as 'no value'
    }
}
