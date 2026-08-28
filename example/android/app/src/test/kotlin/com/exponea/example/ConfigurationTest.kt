package com.exponea.example

import com.exponea.data.ExponeaConfigurationParser
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import com.exponea.sdk.models.ExponeaConfiguration.TokenFrequency
import com.exponea.sdk.models.ProjectConfig
import com.exponea.sdk.models.StreamConfig
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class ConfigurationTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("configuration")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 7)
    }

    @Test
    fun `parse empty map`() {
        try {
            val parser = ExponeaConfigurationParser()
            parser.parseConfig(data[0])
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Property projectToken is required.", e.message)
        }
    }

    @Test
    fun `parse minimal config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[1])
        val defaultConfig = ExponeaConfiguration()

        assertEquals(config.projectToken, "mock-project-token")
        assertEquals(config.authorization, "Token mock-auth-token")
        assertEquals(config.baseURL, defaultConfig.baseURL)
        assertEquals(config.projectRouteMap.isEmpty(), true)
        assertEquals(config.defaultProperties.isEmpty(), true)
        assertEquals(config.maxTries, defaultConfig.maxTries)
        assertEquals(config.sessionTimeout, defaultConfig.sessionTimeout, 0.0)
        assertEquals(config.automaticSessionTracking, defaultConfig.automaticSessionTracking)
        assertEquals(config.tokenTrackFrequency, defaultConfig.tokenTrackFrequency)
        assertEquals(config.requirePushAuthorization, defaultConfig.requirePushAuthorization)
        assertEquals(config.allowDefaultCustomerProperties, defaultConfig.allowDefaultCustomerProperties)
        assertEquals(config.advancedAuthEnabled, defaultConfig.advancedAuthEnabled)
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, defaultConfig.inAppContentBlockPlaceholdersAutoLoad)
        assertEquals(config.appInboxDetailImageInset, defaultConfig.appInboxDetailImageInset)
        assertEquals(config.allowWebViewCookies, defaultConfig.allowWebViewCookies)
        assertEquals(config.manualSessionAutoClose, defaultConfig.manualSessionAutoClose)
        assertEquals(config.regenerateDeviceIdOnAnonymize, defaultConfig.regenerateDeviceIdOnAnonymize)
    }

    @Test
    fun `parse defaultSession config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[2])

        assertEquals(config.projectToken, "mock-project-token")
        assertEquals(config.authorization, "Token mock-auth-token")
        assertEquals(config.baseURL, "http://mock.base.url.com")
        assertEquals(config.projectRouteMap.size, 1)
        val projectList = config.projectRouteMap[EventType.BANNER]!!
        assertEquals(projectList.size, 1)
        assertEquals(projectList[0].projectToken, "other-project-token")
        assertEquals(projectList[0].authorization, "Token other-auth-token")
        assertEquals(projectList[0].baseUrl, config.baseURL)
        val props = config.defaultProperties
        assertEquals(props.size, 5)
        assertEquals(props["string"], "value")
        assertEquals(props["boolean"], false)
        assertEquals(props["number"], 3.14159)
        assertEquals(props["array"], listOf("value1", "value2"))
        assertEquals(props["object"], mapOf("key" to "value"))
        assertEquals(config.maxTries, 10)
        assertEquals(config.sessionTimeout.toInt(), 60)
        assertEquals(config.automaticSessionTracking, true)
        assertEquals(config.tokenTrackFrequency, TokenFrequency.DAILY)
        assertEquals(config.requirePushAuthorization, ExponeaConfiguration().requirePushAuthorization)
        assertEquals(config.allowDefaultCustomerProperties, true)
        assertEquals(config.advancedAuthEnabled, true)
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, listOf("mock-placeholder-1", "mock-placeholder-2"))
        assertEquals(config.appInboxDetailImageInset, 16)
        assertEquals(config.allowWebViewCookies, true)
        assertEquals(config.manualSessionAutoClose, true)
        assertEquals(config.regenerateDeviceIdOnAnonymize, true)
        assertEquals(config.applicationId, "default-application")
    }

    @Test
    fun `parse full config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[3])

        assertEquals(config.projectToken, "mock-project-token")
        assertEquals(config.authorization, "Token mock-auth-token")
        assertEquals(config.baseURL, "http://mock.base.url.com")
        assertEquals(config.projectRouteMap.size, 1)
        val projectList = config.projectRouteMap[EventType.BANNER]!!
        assertEquals(projectList.size, 1);
        assertEquals(projectList[0].projectToken, "other-project-token")
        assertEquals(projectList[0].authorization, "Token other-auth-token")
        assertEquals(projectList[0].baseUrl, config.baseURL)
        val props = config.defaultProperties
        assertEquals(props.size, 5)
        assertEquals(props["string"], "value")
        assertEquals(props["boolean"], false)
        assertEquals(props["number"], 3.14159)
        assertEquals(props["array"], listOf("value1", "value2"))
        assertEquals(props["object"], mapOf("key" to "value"))
        assertEquals(config.maxTries, 10)
        assertEquals(config.sessionTimeout.toInt(), 45)
        assertEquals(config.automaticSessionTracking, true)
        assertEquals(config.tokenTrackFrequency, TokenFrequency.DAILY)
        assertEquals(config.requirePushAuthorization, ExponeaConfiguration().requirePushAuthorization)
        assertEquals(config.allowDefaultCustomerProperties, true)
        assertEquals(config.advancedAuthEnabled, true)
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, listOf("mock-placeholder-1", "mock-placeholder-2"))
        assertEquals(config.appInboxDetailImageInset, 16)
        assertEquals(config.allowWebViewCookies, true)
        assertEquals(config.manualSessionAutoClose, true)
        assertEquals(config.regenerateDeviceIdOnAnonymize, true)
        assertEquals(config.applicationId, "default-application")
    }

    @Test
    fun `parse normalized minimal config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[4])
        val integration = config.integrationConfig as ProjectConfig

        assertEquals(integration.projectToken, "mock-project-token")
        assertEquals(integration.authorization, "Token mock-auth-token")
        assertEquals(config.integrationRouteMap.isEmpty(), true)
    }

    @Test
    fun `parse normalized defaultSession config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[5])
        val integration = config.integrationConfig as ProjectConfig

        assertEquals(integration.projectToken, "mock-project-token")
        assertEquals(integration.authorization, "Token mock-auth-token")
        assertEquals(integration.baseUrl, "http://mock.base.url.com")
        assertEquals(config.integrationRouteMap.size, 1)
        val projectList = config.integrationRouteMap[EventType.BANNER]!!
        assertEquals(projectList.size, 1)
        assertEquals(projectList[0].projectToken, "other-project-token")
        assertEquals(projectList[0].authorization, "Token other-auth-token")
        // Route map entry has no baseUrl of its own, so it must use the SDK default,
        // NOT inherit the parent project's baseUrl (http://mock.base.url.com).
        assertEquals(projectList[0].baseUrl, ExponeaConfiguration().baseURL)
    }

    @Test
    fun `parse integration route map entry does not inherit parent base url`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(
            mapOf(
                "integrationConfig" to mapOf(
                    "projectToken" to "mock-project-token",
                    "authorizationToken" to "mock-auth-token",
                    "baseUrl" to "https://project.example.com",
                ),
                "integrationRouteMap" to mapOf(
                    "PAYMENT" to listOf(
                        mapOf(
                            "projectToken" to "other-project-token",
                            "authorizationToken" to "other-auth-token",
                        ),
                    ),
                ),
            ),
        )
        val integration = config.integrationConfig as ProjectConfig
        assertEquals(integration.baseUrl, "https://project.example.com")

        val projectList = config.integrationRouteMap[EventType.PAYMENT]!!
        assertEquals(projectList.size, 1)
        assertEquals(projectList[0].baseUrl, ExponeaConfiguration().baseURL)
    }

    @Test
    fun `parse stream integration config`() {
        val streamFixtures = BaseTest.readMapData("integration_config")
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(
            mapOf("integrationConfig" to streamFixtures[4])
        )
        val integration = config.integrationConfig as StreamConfig

        assertEquals(integration.streamId, "mock-stream-id")
        assertEquals(integration.baseUrl, "https://stream.exponea.com")
        assertEquals(config.integrationRouteMap.isEmpty(), true)
        assertEquals(config.advancedAuthEnabled, false)
    }
}
