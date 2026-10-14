package com.exponea.example

import android.app.Application
import android.content.Context

/** Exposes the application context to native helpers such as the customer token provider. */
class ExampleApplication : Application() {
    companion object {
        var context: Context? = null
            private set
    }

    override fun onCreate() {
        super.onCreate()
        context = applicationContext
    }
}
