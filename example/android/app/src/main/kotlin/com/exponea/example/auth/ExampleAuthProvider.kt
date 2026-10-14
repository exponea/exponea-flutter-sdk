package com.exponea.example.auth

import com.exponea.sdk.services.AuthorizationProvider

/**
 * Supplies the customer token when the auth form's "Advanced auth key" is set
 * (registered in the manifest as `ExponeaAuthProvider`).
 */
class ExampleAuthProvider : AuthorizationProvider {
    override fun getAuthorizationToken(): String? = CustomerTokenStorage.INSTANCE.retrieveJwtToken()
}
