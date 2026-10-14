package com.exponea.example.auth

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CustomerTokenStorageTest {
    private val janeConfig = CustomerTokenStorage.Config(
        host = "https://api.example.com",
        projectToken = "project",
        publicKey = "key",
        customerIds = mapOf("registered" to "jane@example.com")
    )

    @Test
    fun `caches the token for the same configuration`() {
        var requests = 0
        val storage = CustomerTokenStorage({ janeConfig }, { requests++; "token-$requests" })

        assertEquals("token-1", storage.retrieveJwtToken(now = 0))
        assertEquals("token-1", storage.retrieveJwtToken(now = 60_000))
        assertEquals(1, requests)
    }

    @Test
    fun `requests a new token when the customer changes`() {
        var config = janeConfig
        var requests = 0
        val storage = CustomerTokenStorage({ config }, { requests++; "token-${it.customerIds}" })

        storage.retrieveJwtToken(now = 0)
        config = janeConfig.copy(customerIds = mapOf("registered" to "joe@example.com"))

        assertEquals("token-{registered=joe@example.com}", storage.retrieveJwtToken(now = 1_000))
        assertEquals(2, requests)
    }

    @Test
    fun `retries a failed request only after 5 minutes`() {
        var requests = 0
        val storage = CustomerTokenStorage({ janeConfig }, { requests++; null })

        assertNull(storage.retrieveJwtToken(now = 1))
        assertNull(storage.retrieveJwtToken(now = 4 * 60_000))
        assertEquals(1, requests)
        storage.retrieveJwtToken(now = 6 * 60_000)
        assertEquals(2, requests)
    }
}
