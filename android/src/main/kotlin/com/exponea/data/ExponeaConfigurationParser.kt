package com.exponea.data

import android.app.NotificationManager
import com.exponea.exception.ExponeaDataException
import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaConfiguration
import com.exponea.sdk.models.ExponeaProject
import java.lang.Exception

@Suppress("UNCHECKED_CAST")
class ExponeaConfigurationParser {
    fun parseConfig(map: Map<String, Any?>): ExponeaConfiguration {
        return ExponeaConfiguration().apply {
            projectToken = map.getRequired("projectToken")
            authorization = "Token ${ map.getRequired<String>("authorizationToken") }"
            map.getOptional<String>("baseUrl")?.let {
                baseURL = it
            }

            map.getOptional<Map<String, Any?>>("projectMapping")?.let {
                projectRouteMap = parseProjectMapping(it, baseURL)
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
            map.getOptional<Boolean>("advancedAuthEnabled")?.let {
                advancedAuthEnabled = it
            }
            map.getOptional<ArrayList<String>>("inAppContentBlockPlaceholdersAutoLoad")?.let {
                inAppContentBlockPlaceholdersAutoLoad = it
            }
        }
    }

    fun parseConfigChange(map: Map<String, Any?>, baseUrl: String): ExponeaConfigurationChange {
        val project = map.getOptional<Map<String, Any?>>("project")?.let {
            parseExponeaProject(it, baseUrl)
        }
        val mapping = map.getOptional<Map<String, Any?>>("mapping")?.let {
            parseProjectMapping(it, project?.baseUrl ?: baseUrl)
        }
        return ExponeaConfigurationChange(project, mapping)
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
        }
    }

    fun parseExponeaProject(map: Map<String, Any?>, defaultBaseUrl: String): ExponeaProject {
        val baseUrl: String? = map.getOptional("baseUrl")
        val projectToken: String = map.getRequired("projectToken")
        val authorizationToken: String = map.getRequired("authorizationToken")
        return ExponeaProject(baseUrl ?: defaultBaseUrl, projectToken, "Token $authorizationToken")
    }

    private fun parseProjectMapping(map: Map<String, Any?>, defaultBaseUrl: String): Map<EventType, List<ExponeaProject>> {
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
                    parseExponeaProject(it, defaultBaseUrl)
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
