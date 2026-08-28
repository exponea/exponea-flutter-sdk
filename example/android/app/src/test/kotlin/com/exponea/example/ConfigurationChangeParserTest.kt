package com.exponea.example

import com.exponea.data.ConfigurationChangeParser
import com.exponea.data.ExponeaConfigurationParser
import com.exponea.data.ParsedConfigurationChange
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import com.exponea.sdk.models.ProjectConfig
import com.exponea.sdk.models.StreamConfig
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.BeforeClass
import org.junit.Test

class ConfigurationChangeParserTest {
    companion object {
        lateinit var legacyData: List<Map<String, Any?>>
        lateinit var integrationData: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            legacyData = BaseTest.readMapData("configuration_change")
            integrationData = BaseTest.readMapData("integration_configuration_change")
        }
    }

    @Test
    fun `parse legacy empty map`() {
        val parser = ExponeaConfigurationParser()
        val change = ConfigurationChangeParser.parse(legacyData[0], parser)

        assertTrue(change is ParsedConfigurationChange.Legacy)
        val legacy = change as ParsedConfigurationChange.Legacy
        assertNull(legacy.change.project)
        assertNull(legacy.change.mapping)
    }

    @Test
    fun `parse stream integration change`() {
        val parser = ExponeaConfigurationParser()
        val change = ConfigurationChangeParser.parse(integrationData[1], parser)

        assertTrue(change is ParsedConfigurationChange.Integration)
        val integration = change as ParsedConfigurationChange.Integration
        val stream = integration.integrationConfig as StreamConfig

        assertEquals(stream.streamId, "mock-stream-id")
        assertNull(integration.integrationRouteMap)
    }

    @Test
    fun `parse project integration change with route map`() {
        val parser = ExponeaConfigurationParser()
        val change = ConfigurationChangeParser.parse(integrationData[3], parser)

        assertTrue(change is ParsedConfigurationChange.Integration)
        val integration = change as ParsedConfigurationChange.Integration
        val project = integration.integrationConfig as ProjectConfig

        assertEquals(project.projectToken, "mock-project-token")
        assertEquals(project.authorization, "Token mock-auth-token")
        assertEquals(project.baseUrl, "https://api.exponea.com")
        assertEquals(integration.integrationRouteMap?.size, 1)
        val projectList = integration.integrationRouteMap?.get(EventType.PAYMENT)!!
        assertEquals(projectList.size, 1)
        assertEquals(projectList[0].projectToken, "other-project-token")
    }

    @Test
    fun `anonymize route map entry does not inherit parent base url`() {
        val parser = ExponeaConfigurationParser()
        val change = ConfigurationChangeParser.parse(
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
            parser,
        )

        assertTrue(change is ParsedConfigurationChange.Integration)
        val integration = change as ParsedConfigurationChange.Integration
        val project = integration.integrationConfig as ProjectConfig
        assertEquals(project.baseUrl, "https://project.example.com")

        val projectList = integration.integrationRouteMap?.get(EventType.PAYMENT)!!
        assertEquals(projectList.size, 1)
        // Route map entry has no baseUrl, so it must fall back to the SDK default,
        // not inherit the parent project's https://project.example.com.
        assertEquals(projectList[0].baseUrl, ExponeaConfiguration().baseURL)
    }
}
