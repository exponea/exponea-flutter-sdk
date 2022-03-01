package com.exponea.example

import com.exponea.sdk.util.Logger.Level
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class LogLevelTest {
    companion object {
        lateinit var data: List<String>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readStringData("log_level")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 6)
    }

    @Test
    fun `encode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(Level.values()[i].name, data[i])
        }
    }

    @Test
    fun `decode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(Level.valueOf(data[i]), Level.values()[i])
        }
    }
}
