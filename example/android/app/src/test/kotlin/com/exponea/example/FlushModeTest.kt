package com.exponea.example

import com.exponea.sdk.models.FlushMode
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class FlushModeTest {
    companion object {
        lateinit var data: List<String>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readStringData("flush_mode")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(FlushMode.values()[i].name, data[i])
        }
    }

    @Test
    fun `decode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(FlushMode.valueOf(data[i]), FlushMode.values()[i])
        }
    }
}
