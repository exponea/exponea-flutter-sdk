package com.exponea.data

import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.IntegrationConfig
import com.exponea.sdk.models.ProjectConfig

sealed class ParsedConfigurationChange {
    data class Legacy(
        val change: ExponeaConfigurationChange,
    ) : ParsedConfigurationChange()

    data class Integration(
        val integrationConfig: IntegrationConfig,
        val integrationRouteMap: Map<EventType, List<ProjectConfig>>?,
    ) : ParsedConfigurationChange()
}

object ConfigurationChangeParser {
    fun parse(
        map: Map<String, Any?>,
        parser: ExponeaConfigurationParser,
    ): ParsedConfigurationChange {
        if (map.containsKey("integrationConfig")) {
            val integrationConfigMap = map.getOptional<Map<String, Any?>>("integrationConfig")
                ?: throw com.exponea.exception.ExponeaDataException(
                    "integrationConfig is required.",
                )
            val integrationConfig = parser.parseIntegrationConfig(integrationConfigMap)
            val integrationRouteMap = map.getOptional<Map<String, Any?>>("integrationRouteMap")
                ?.let {
                    parser.parseIntegrationRouteMap(it)
                }
            return ParsedConfigurationChange.Integration(
                integrationConfig = integrationConfig,
                integrationRouteMap = integrationRouteMap,
            )
        }

        return ParsedConfigurationChange.Legacy(
            parser.parseConfigChange(map),
        )
    }
}
