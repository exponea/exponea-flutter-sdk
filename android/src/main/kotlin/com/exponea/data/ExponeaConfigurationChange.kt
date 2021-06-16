package com.exponea.data

import com.exponea.sdk.models.EventType
import com.exponea.sdk.models.ExponeaProject

data class ExponeaConfigurationChange(
    val project: ExponeaProject?,
    val mapping: Map<EventType, List<ExponeaProject>>?
)
