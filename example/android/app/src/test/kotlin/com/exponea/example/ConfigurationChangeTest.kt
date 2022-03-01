package com.exponea.example

import com.exponea.data.ExponeaConfigurationParser
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class ConfigurationChangeTest {
    companion object {
        private val DEFAULT_URL = "default-base-url"

        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("configuration_change")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `parse empty map`() {
        val parser = ExponeaConfigurationParser()
        val decoded = parser.parseConfigChange(data[0], DEFAULT_URL)

        assertEquals(decoded.project, null)
        assertEquals(decoded.mapping, null)
    }

    @Test
    fun `parse minimal`() {
        val parser = ExponeaConfigurationParser()
        val decoded = parser.parseConfigChange(data[1], DEFAULT_URL)

        assertEquals(decoded.project != null, true)
        val project = decoded.project!!
        assertEquals(project.projectToken, "mock-project-token")
        assertEquals(project.authorization, "Token mock-auth-token")
        assertEquals(project.baseUrl, DEFAULT_URL)
        assertEquals(decoded.mapping, null)
    }

    @Test
    fun `parse with base url`() {
        val parser = ExponeaConfigurationParser()
        val decoded = parser.parseConfigChange(data[2], DEFAULT_URL)

        assertEquals(decoded.project != null, true)
        val project = decoded.project!!
        assertEquals(project.projectToken, "mock-project-token")
        assertEquals(project.authorization, "Token mock-auth-token")
        assertEquals(project.baseUrl, "http://mock.base.url.com")
        assertEquals(decoded.mapping, null)
    }

    @Test
    fun `parse full`() {
        val parser = ExponeaConfigurationParser()
        val decoded = parser.parseConfigChange(data[3], DEFAULT_URL)

        assertEquals(decoded.project != null, true)
        val project = decoded.project!!
        assertEquals(project.projectToken, "mock-project-token")
        assertEquals(project.authorization, "Token mock-auth-token")
        assertEquals(project.baseUrl, "http://mock.base.url.com")
        assertEquals(decoded.mapping != null, true)
        val mapping = decoded.mapping!!
        assertEquals(mapping.size, 1);
        val projectList = mapping[EventType.PAYMENT]!!;
        assertEquals(projectList.size, 1);
        assertEquals(projectList[0].projectToken, "other-project-token");
        assertEquals(projectList[0].authorization, "Token other-auth-token");
        assertEquals(projectList[0].baseUrl, project.baseUrl);
    }
}
