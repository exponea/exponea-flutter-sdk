//
//  ExampleAuthProvider.swift
//  Runner
//
//  Supplies the customer token when the auth form's "Advanced auth key" is set.
//  The SDK finds it by the Objective-C name `ExponeaAuthProvider`.
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
