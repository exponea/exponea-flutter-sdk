package com.exponea.data

import com.google.gson.JsonElement
import com.google.gson.JsonPrimitive

class JsonElementEncoder {
    companion object {
        fun encode(element: JsonElement): Any {
            if (element is JsonPrimitive) {
                when {
                    element.isBoolean -> {
                        return element.asBoolean
                    }
                    element.isNumber -> {
                        return element.asNumber
                    }
                    element.isString -> {
                        return element.asString
                    }
                }
            }
            // fallback to toString()
            return element.toString()
        }
    }
}
