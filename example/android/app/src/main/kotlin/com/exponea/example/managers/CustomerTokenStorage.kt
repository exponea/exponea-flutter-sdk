package com.exponea.example.managers

import android.content.Context
import android.content.SharedPreferences
import android.preference.PreferenceManager
import com.exponea.example.MainActivity
import com.exponea.sdk.util.Logger
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import java.util.concurrent.TimeUnit
import kotlin.math.abs

/**
 * !!! WARN for developers.
 * This implementation is just proof of concept. Do not rely on any part of it as possible solution for Customer Token
 * handling.
 * It is in your own interest to provide proper token generating and handling of its cache, expiration and secured storing.
 */
class CustomerTokenStorage(
    private var networkManager: NetworkManager = NetworkManager(),
    private val gson: Gson = Gson(),
    private val prefs: SharedPreferences = MainActivity.APP_CONTEXT!!.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
) {

    companion object {
        private const val CUSTOMER_TOKEN_CONF = "CustomerTokenConf"
        val INSTANCE = CustomerTokenStorage()
    }

    private var currentConf: Config? = null

    private var tokenCache: String? = null

    private var lastTokenRequestTime: Long = 0

    fun retrieveJwtToken(): String? {
        validateChangedConf()
        val now = System.currentTimeMillis()
        if (TimeUnit.MILLISECONDS.toMinutes(abs(now - lastTokenRequestTime)) < 5) {
            // allows request for token once per 5 minutes, doesn't care if cache is NULL
            Logger.d(this, "[CTS] Token retrieved within 5min, using cache $tokenCache")
            return tokenCache
        }
        lastTokenRequestTime = now
        if (tokenCache != null) {
            // return cached value
            Logger.d(this, "[CTS] Token cache returned $tokenCache")
            return tokenCache
        }
        synchronized(this) {
            // recheck nullity just in case
            if (tokenCache == null) {
                tokenCache = loadJwtToken()
            }
        }
        return tokenCache
    }

    private fun validateChangedConf() {
        val storedConf = loadConfiguration()
        if (currentConf != storedConf) {
            // reset token
            tokenCache = null
            lastTokenRequestTime = 0
        }
        currentConf = storedConf
    }

    private fun loadJwtToken(): String? {
        currentConf = loadConfiguration()
        val host = currentConf?.host
        val projectToken = currentConf?.projectToken
        val publicKey = currentConf?.publicKey
        val customerIds = currentConf?.customerIds
        if (
            host == null || projectToken == null ||
            publicKey == null || customerIds == null || customerIds.size == 0
        ) {
            Logger.d(this, "[CTS] Not configured yet")
            return null
        }
        val reqBody = hashMapOf(
            "project_id" to projectToken,
            "kid" to publicKey,
            "sub" to customerIds
        )
        val jsonRequest = gson.toJson(reqBody)
        val response = networkManager.post(
            "$host/webxp/exampleapp/customertokens",
            null,
            jsonRequest
        ).execute()
        Logger.d(this, "[CTS] Requested for token with $jsonRequest")
        if (!response.isSuccessful) {
            if (response.code == 404) {
                // that is fine, only some BE has this endpoint
                Logger.d(this, "[CTS] Token request returns 404")
                return null
            }
            Logger.e(this, "[CTS] Token request returns ${response.code}")
            return null
        }
        val jsonResponse = response.body?.string()
        val responseData = try {
            gson.fromJson(jsonResponse, Response::class.java)
        } catch (e: Exception) {
            Logger.e(this, "[CTS] Token cannot be parsed from $jsonResponse")
            return null
        }
        if (responseData?.token == null) {
            Logger.e(this, "[CTS] Token received NULL")
        }
        Logger.d(this, "[CTS] Token received ${responseData?.token}")
        return responseData?.token
    }

    private fun loadConfiguration(): Config {
        return Config(
            // See config.dart how are stored fields
            host = prefs.getString("flutter.base_url", null),
            projectToken = prefs.getString("flutter.project_token", null),
            publicKey = prefs.getString("flutter.advanced_auth_token", null),
            // See home.dart how are stored customerIds in _identifyCustomer method
            customerIds = prefs.getString("flutter.customer_ids", null).let {
                gson.fromJson(it ?: "{}", object : TypeToken<HashMap<String, String>>() {}.type)
            }
        )
    }

    data class Response(
        @SerializedName("customer_token")
        val token: String?,

        @SerializedName("expire_time")
        val expiration: Int?
    )

    data class Config(
        var host: String? = null,
        var projectToken: String? = null,
        var publicKey: String? = null,
        var customerIds: HashMap<String, String>? = null

    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as Config

            if (host != other.host) return false
            if (projectToken != other.projectToken) return false
            if (publicKey != other.publicKey) return false
            if (customerIds != other.customerIds) return false

            return true
        }

        override fun hashCode(): Int {
            var result = host?.hashCode() ?: 0
            result = 31 * result + (projectToken?.hashCode() ?: 0)
            result = 31 * result + (publicKey?.hashCode() ?: 0)
            result = 31 * result + (customerIds?.hashCode() ?: 0)
            return result
        }
    }
}
