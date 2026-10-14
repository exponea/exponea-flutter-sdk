package com.exponea.example.auth

import android.content.Context
import com.exponea.example.ExampleApplication
import com.exponea.sdk.util.Logger
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.TimeUnit
import kotlin.math.abs
import org.json.JSONObject

/**
 * !!! Proof of concept for the example app only, ported from the legacy example and the Android
 * example app. Do not rely on it for real customer token handling: generate, cache, expire and
 * store tokens securely in your own backend and app.
 *
 * Reads the auth form values persisted by the Flutter app (`shared_preferences`, `flutter.` prefix)
 * and requests a token from `{base_url}/webxp/exampleapp/customertokens`.
 */
class CustomerTokenStorage(
    private val loadConfig: () -> Config = ::loadConfigFromFlutterPreferences,
    private val requestToken: (Config) -> String? = ::requestTokenFromBackend
) {
    companion object {
        val INSTANCE = CustomerTokenStorage()

        private const val PREFERENCES = "FlutterSharedPreferences"

        private fun loadConfigFromFlutterPreferences(): Config {
            val prefs = ExampleApplication.context
                ?.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                ?: return Config()
            val customerIds = prefs.getString("flutter.customer_ids", null)?.let { json ->
                try {
                    val obj = JSONObject(json)
                    obj.keys().asSequence().associateWith { obj.getString(it) }
                } catch (e: Exception) {
                    null
                }
            }
            return Config(
                host = prefs.getString("flutter.base_url", null),
                projectToken = prefs.getString("flutter.project_token", null),
                publicKey = prefs.getString("flutter.advanced_auth_token", null),
                customerIds = customerIds
            )
        }

        private fun requestTokenFromBackend(config: Config): String? {
            val body = JSONObject()
                .put("project_id", config.projectToken)
                .put("kid", config.publicKey)
                .put("sub", JSONObject(config.customerIds ?: emptyMap<String, String>()))
                .toString()
            val connection = URL("${config.host}/webxp/exampleapp/customertokens")
                .openConnection() as HttpURLConnection
            return try {
                connection.requestMethod = "POST"
                connection.doOutput = true
                connection.setRequestProperty("Content-Type", "application/json")
                connection.outputStream.use { it.write(body.toByteArray()) }
                when (val code = connection.responseCode) {
                    in 200..299 -> {
                        val response = connection.inputStream.bufferedReader().use { it.readText() }
                        JSONObject(response).optString("customer_token").ifEmpty { null }
                    }
                    404 -> {
                        // Only some backends expose this endpoint.
                        Logger.d(this, "[CTS] Customer token endpoint not available (404)")
                        null
                    }
                    else -> {
                        Logger.e(this, "[CTS] Customer token request returned $code")
                        null
                    }
                }
            } catch (e: Exception) {
                Logger.e(this, "[CTS] Customer token request failed: $e")
                null
            } finally {
                connection.disconnect()
            }
        }
    }

    data class Config(
        val host: String? = null,
        val projectToken: String? = null,
        val publicKey: String? = null,
        val customerIds: Map<String, String>? = null
    ) {
        val isComplete: Boolean
            get() = !host.isNullOrEmpty() && !projectToken.isNullOrEmpty() &&
                !publicKey.isNullOrEmpty() && !customerIds.isNullOrEmpty()
    }

    private var currentConfig: Config? = null
    private var tokenCache: String? = null
    private var lastTokenRequestTime: Long = 0

    @Synchronized
    fun retrieveJwtToken(now: Long = System.currentTimeMillis()): String? {
        val config = loadConfig()
        if (config != currentConfig) {
            // A different customer or project needs a new token.
            tokenCache = null
            lastTokenRequestTime = 0
            currentConfig = config
        }
        if (tokenCache != null) {
            return tokenCache
        }
        if (lastTokenRequestTime != 0L &&
            TimeUnit.MILLISECONDS.toMinutes(abs(now - lastTokenRequestTime)) < 5
        ) {
            // At most one request per 5 minutes, even when the last one returned nothing.
            return null
        }
        if (!config.isComplete) {
            Logger.d(this, "[CTS] Not configured yet")
            return null
        }
        lastTokenRequestTime = now
        tokenCache = requestToken(config)
        return tokenCache
    }
}
