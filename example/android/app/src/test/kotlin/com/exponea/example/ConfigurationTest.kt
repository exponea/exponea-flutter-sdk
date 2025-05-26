package com.exponea.example

import com.exponea.data.ExponeaConfigurationParser
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import com.exponea.sdk.models.ExponeaConfiguration.TokenFrequency
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
        assertEquals(data.size, 4)
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
        assertEquals(config.authorization, "Token mock-auth-token");
        assertEquals(config.baseURL, defaultConfig.baseURL);
        assertEquals(config.projectRouteMap.isEmpty(), true);
        assertEquals(config.defaultProperties.isEmpty(), true);
        assertEquals(config.maxTries, defaultConfig.maxTries);
        assertEquals(config.sessionTimeout, defaultConfig.sessionTimeout, 0.0);
        assertEquals(config.automaticSessionTracking, defaultConfig.automaticSessionTracking);
        assertEquals(config.tokenTrackFrequency, defaultConfig.tokenTrackFrequency);
        assertEquals(config.requirePushAuthorization, defaultConfig.requirePushAuthorization);
        assertEquals(config.allowDefaultCustomerProperties, defaultConfig.allowDefaultCustomerProperties);
        assertEquals(config.advancedAuthEnabled, defaultConfig.advancedAuthEnabled);
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, defaultConfig.inAppContentBlockPlaceholdersAutoLoad);
        assertEquals(config.appInboxDetailImageInset, defaultConfig.appInboxDetailImageInset);
        assertEquals(config.allowWebViewCookies, defaultConfig.allowWebViewCookies);
        assertEquals(config.manualSessionAutoClose, defaultConfig.manualSessionAutoClose);
    }

    @Test
    fun `parse defaultSession config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[2])

        assertEquals(config.projectToken, "mock-project-token")
        assertEquals(config.authorization, "Token mock-auth-token");
        assertEquals(config.baseURL, "http://mock.base.url.com");
        assertEquals(config.projectRouteMap.size, 1);
        val projectList = config.projectRouteMap[EventType.BANNER]!!
        assertEquals(projectList.size, 1);
        assertEquals(projectList[0].projectToken, "other-project-token");
        assertEquals(projectList[0].authorization, "Token other-auth-token");
        assertEquals(projectList[0].baseUrl, config.baseURL);
        val props = config.defaultProperties
        assertEquals(props.size, 5);
        assertEquals(props["string"], "value");
        assertEquals(props["boolean"], false);
        assertEquals(props["number"], 3.14159);
        assertEquals(props["array"], listOf("value1", "value2"));
        assertEquals(props["object"], mapOf("key" to "value"));
        assertEquals(config.maxTries, 10);
        assertEquals(config.sessionTimeout.toInt(), 60);
        assertEquals(config.automaticSessionTracking, true);
        assertEquals(config.tokenTrackFrequency, TokenFrequency.DAILY);
        assertEquals(config.requirePushAuthorization, true);
        assertEquals(config.allowDefaultCustomerProperties, true);
        assertEquals(config.advancedAuthEnabled, true);
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, listOf("mock-placeholder-1", "mock-placeholder-2"));
        assertEquals(config.appInboxDetailImageInset, 16);
        assertEquals(config.allowWebViewCookies, true);
        assertEquals(config.manualSessionAutoClose, true);
    }

    @Test
    fun `parse full config`() {
        val parser = ExponeaConfigurationParser()
        val config = parser.parseConfig(data[3])

        assertEquals(config.projectToken, "mock-project-token")
        assertEquals(config.authorization, "Token mock-auth-token");
        assertEquals(config.baseURL, "http://mock.base.url.com");
        assertEquals(config.projectRouteMap.size, 1);
        val projectList = config.projectRouteMap[EventType.BANNER]!!
        assertEquals(projectList.size, 1);
        assertEquals(projectList[0].projectToken, "other-project-token");
        assertEquals(projectList[0].authorization, "Token other-auth-token");
        assertEquals(projectList[0].baseUrl, config.baseURL);
        val props = config.defaultProperties
        assertEquals(props.size, 5);
        assertEquals(props["string"], "value");
        assertEquals(props["boolean"], false);
        assertEquals(props["number"], 3.14159);
        assertEquals(props["array"], listOf("value1", "value2"));
        assertEquals(props["object"], mapOf("key" to "value"));
        assertEquals(config.maxTries, 10);
        assertEquals(config.sessionTimeout.toInt(), 45);
        assertEquals(config.automaticSessionTracking, true);
        assertEquals(config.tokenTrackFrequency, TokenFrequency.DAILY);
        assertEquals(config.requirePushAuthorization, true);
        assertEquals(config.allowDefaultCustomerProperties, true);
        assertEquals(config.advancedAuthEnabled, true);
        assertEquals(config.inAppContentBlockPlaceholdersAutoLoad, listOf("mock-placeholder-1", "mock-placeholder-2"));
        assertEquals(config.appInboxDetailImageInset, 16);
        assertEquals(config.allowWebViewCookies, true);
        assertEquals(config.manualSessionAutoClose, true);
    }
}
