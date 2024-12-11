package com.exponea.data

enum class InAppMessageActionType(val value: String) {
    CLICK("click"),
    CLOSE("close"),
    ERROR("error"),
    SHOW("show");

    companion object {
        fun find(value: String?) = InAppMessageActionType.values().find { it.value.equals(value, ignoreCase = true) }
    }
}