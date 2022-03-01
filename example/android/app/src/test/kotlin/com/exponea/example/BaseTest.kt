package com.exponea.example

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.File

abstract class BaseTest {
    companion object {
        fun readMapData(fileName: String): List<Map<String, Any?>> {
            val file = File("../../../test/values/$fileName.json")
            val fileData = file.readText(Charsets.UTF_8)
            val expectedType = object : TypeToken<List<Map<String, Any?>>?>() {}.getType()
            return Gson().fromJson(fileData, expectedType) as List<Map<String, Any?>>
        }

        fun readStringData(fileName: String): List<String> {
            val file = File("../../../test/values/$fileName.json")
            val fileData = file.readText(Charsets.UTF_8)
            val expectedType = object : TypeToken<List<String>?>() {}.getType()
            return Gson().fromJson(fileData, expectedType) as List<String>
        }

        fun toJson(data: Map<String, Any?>): String {
            return Gson().toJson(data)
        }
    }
}
