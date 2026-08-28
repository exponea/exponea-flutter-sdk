package com.exponea.data

import android.app.NotificationManager
import com.exponea.exception.ExponeaDataException
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import com.exponea.sdk.models.ExponeaProject
import com.exponea.sdk.models.IntegrationConfig
import com.exponea.sdk.models.ProjectConfig
import com.exponea.sdk.models.StreamConfig
import java.lang.Exception

@Suppress("UNCHECKED_CAST")
class ExponeaConfigurationParser {
    fun parseConfig(map: Map<String, Any?>): ExponeaConfiguration {
        return ExponeaConfiguration().apply {
            val integrationConfigMap = map.getOptional<Map<String, Any?>>("integrationConfig")
            if (integrationConfigMap != null) {
                integrationConfig = parseIntegrationConfig(integrationConfigMap)
                map.getOptional<Map<String, Any?>>("integrationRouteMap")?.let {
                    integrationRouteMap = parseIntegrationRouteMap(it)
                }
            } else {
                projectToken = map.getRequired("projectToken")
                authorization = "Token ${ map.getRequired<String>("authorizationToken") }"
                map.getOptional<String>("baseUrl")?.let {
                    baseURL = it
                }

                map.getOptional<Map<String, Any?>>("projectMapping")?.let {
                    projectRouteMap = parseProjectMapping(it, baseURL)
                }
            }

            map.getOptional<Map<String, Any>>("defaultProperties")?.let {
                defaultProperties = HashMap(it)
            }
            map.getOptional<Double>("flushMaxRetries")?.let {
                maxTries = it.toInt()
            }
            map.getOptional<Double>("sessionTimeout")?.let {
                sessionTimeout = it
            }
            map.getOptional<Boolean>("automaticSessionTracking")?.let {
                automaticSessionTracking = it
            }
            map.getOptional<Boolean>("allowDefaultCustomerProperties")?.let {
                allowDefaultCustomerProperties = it
            }
            map.getOptional<String>("pushTokenTrackingFrequency")?.let {
                try {
                    tokenTrackFrequency = ExponeaConfiguration.TokenFrequency.valueOf(it)
                } catch (e: Exception) {
                    throw ExponeaDataException.invalidValue("pushTokenTrackingFrequency", it)
                }
            }
            map.getOptional<Map<String, Any?>>("android")?.let {
                parseAndroidConfig(it, this)
            }
            if (integrationConfig !is StreamConfig) {
                map.getOptional<Boolean>("advancedAuthEnabled")?.let {
                    advancedAuthEnabled = it
                }
            }
            map.getOptional<ArrayList<String>>("inAppContentBlockPlaceholdersAutoLoad")?.let {
                inAppContentBlockPlaceholdersAutoLoad = it
            }
            map.getOptional<Boolean>("manualSessionAutoClose")?.let {
                manualSessionAutoClose = it
            }
            map.getOptional<Boolean>("regenerateDeviceIdOnAnonymize")?.let {
                regenerateDeviceIdOnAnonymize = it
            }
            map.getOptional<String>("applicationId")?.let {
                applicationId = it
            }
        }
    }

    fun parseConfigChange(map: Map<String, Any?>): ExponeaConfigurationChange {
        val project = map.getOptional<Map<String, Any?>>("project")?.let {
            parseExponeaProject(it)
        }
        val mapping = map.getOptional<Map<String, Any?>>("mapping")?.let {
            parseProjectMapping(it, project?.baseUrl)
        }
        return ExponeaConfigurationChange(project, mapping)
    }

    internal fun parseIntegrationConfig(map: Map<String, Any?>): IntegrationConfig {
        val streamId = map.getOptional<String>("streamId")
        val projectToken = map.getOptional<String>("projectToken")

        if (streamId != null) {
            if (projectToken != null) {
                throw ExponeaDataException(
                    "integrationConfig cannot contain both streamId and projectToken.",
                )
            }
            val baseUrl = map.getOptional<String>("baseUrl")
            return if (baseUrl != null) {
                StreamConfig(streamId = streamId, baseUrl = baseUrl)
            } else {
                StreamConfig(streamId = streamId)
            }
        }

        val authorization = "Token ${ map.getRequired<String>("authorizationToken") }"
        val baseUrl = map.getOptional<String>("baseUrl")
        return if (baseUrl != null) {
            ProjectConfig(
                projectToken = map.getRequired("projectToken"),
                authorization = authorization,
                baseUrl = baseUrl,
            )
        } else {
            ProjectConfig(
                projectToken = map.getRequired("projectToken"),
                authorization = authorization,
            )
        }
    }

    internal fun parseIntegrationRouteMap(
        map: Map<String, Any?>,
    ): Map<EventType, List<ProjectConfig>> {
        val mapping: HashMap<EventType, List<ProjectConfig>> = hashMapOf()

        for (entry in map) {
            val value = entry.value
            if (value == null) {
                continue
            }
            val eventType: EventType
            try {
                eventType = EventType.valueOf(entry.key)
            } catch (e: Exception) {
                throw ExponeaDataException.invalidValue(entry.key, value.toString())
            }
            try {
                val projectList = value as List<Map<String, Any?>>
                mapping[eventType] = projectList.map {
                    parseIntegrationProject(it)
                }
            } catch (e: Exception) {
                throw ExponeaDataException(
                    "Invalid project definition for event type ${entry.key}",
                    e,
                )
            }
        }

        return mapping
    }

    private fun parseIntegrationProject(
        map: Map<String, Any?>,
    ): ProjectConfig {
        val authorization = "Token ${ map.getRequired<String>("authorizationToken") }"
        val baseUrl = map.getOptional<String>("baseUrl")
        return if (baseUrl != null) {
            ProjectConfig(
                projectToken = map.getRequired("projectToken"),
                authorization = authorization,
                baseUrl = baseUrl,
            )
        } else {
            ProjectConfig(
                projectToken = map.getRequired("projectToken"),
                authorization = authorization,
            )
        }
    }

    private fun parseAndroidConfig(map: Map<String, Any?>, configuration: ExponeaConfiguration) {
        configuration.apply {
            map.getOptional<Boolean>("automaticPushNotifications")?.let {
                automaticPushNotification = it
            }
            map.getOptional<Double>("pushIcon")?.let {
                pushIcon = it.toInt()
            }
            map.getOptional<Double>("pushAccentColor")?.let {
                pushAccentColor = it.toUInt().toInt()
            }
            map.getOptional<String>("pushChannelId")?.let {
                pushChannelId = it
            }
            map.getOptional<String>("pushChannelName")?.let {
                pushChannelName = it
            }
            map.getOptional<String>("pushChannelDescription")?.let {
                pushChannelDescription = it
            }
            map.getOptional<String>("pushNotificationImportance")?.let {
                when (it) {
                    "MIN" -> pushNotificationImportance = NotificationManager.IMPORTANCE_MIN
                    "LOW" -> pushNotificationImportance = NotificationManager.IMPORTANCE_LOW
                    "DEFAULT" -> pushNotificationImportance = NotificationManager.IMPORTANCE_DEFAULT
                    "HIGH" -> pushNotificationImportance = NotificationManager.IMPORTANCE_HIGH
                    else -> throw ExponeaDataException.invalidValue("pushNotificationImportance", it)
                }
            }
            map.getOptional<String>("httpLoggingLevel")?.let {
                try {
                    httpLoggingLevel = ExponeaConfiguration.HttpLoggingLevel.valueOf(it)
                } catch (e: Exception) {
                    throw ExponeaDataException.invalidValue("httpLoggingLevel", it)
                }
            }
            map.getOptional<Double>("appInboxDetailImageInset")?.let {
                appInboxDetailImageInset = it.toInt()
            }
            map.getOptional<Boolean>("allowWebViewCookies")?.let {
                allowWebViewCookies = it
            }
        }
    }

    fun parseExponeaProject(
        map: Map<String, Any?>,
        inheritBaseUrl: String? = null,
    ): ExponeaProject {
        val projectToken: String = map.getRequired("projectToken")
        val authorizationToken: String = map.getRequired("authorizationToken")
        val authorization = "Token $authorizationToken"
        map.getOptional<String>("baseUrl")?.let { baseUrl ->
            return ExponeaProject(baseUrl, projectToken, authorization)
        }
        inheritBaseUrl?.let { baseUrl ->
            return ExponeaProject(baseUrl, projectToken, authorization)
        }
        val resolved = ProjectConfig(
            projectToken = projectToken,
            authorization = authorization,
        )
        return ExponeaProject(resolved.baseUrl, projectToken, authorization)
    }

    private fun parseProjectMapping(
        map: Map<String, Any?>,
        inheritBaseUrl: String? = null,
    ): Map<EventType, List<ExponeaProject>> {
        val mapping: HashMap<EventType, List<ExponeaProject>> = hashMapOf()

        for (entry in map) {
            val value = entry.value
            if (value == null) {
                continue
            }
            val eventType: EventType
            try {
                eventType = EventType.valueOf(entry.key)
            } catch (e: Exception) {
                throw ExponeaDataException.invalidValue(entry.key, value.toString())
            }
            try {
                val projectList = value as List<Map<String, Any?>>
                mapping[eventType] = projectList.map {
                    parseExponeaProject(it, inheritBaseUrl)
                }
            } catch (e: Exception) {
                throw ExponeaDataException(
                        "Invalid project definition for event type ${entry.key}",
                        e
                )
            }
        }

        return mapping
    }
}
