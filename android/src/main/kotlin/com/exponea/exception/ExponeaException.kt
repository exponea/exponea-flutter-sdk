package com.exponea.exception

class ExponeaException : Exception {
    companion object {
        fun notConfigured(): ExponeaException {
            return ExponeaException("Exponea SDK is not configured. Call Exponea.configure() before calling functions of the SDK")
        }

        fun alreadyConfigured(): ExponeaException {
            return ExponeaException("Exponea SDK was already configured.")
        }

        fun flushModeNotPeriodic(): ExponeaException {
            return ExponeaException("Flush mode is not periodic.")
        }

        fun flushModeNotManual(): ExponeaException {
            return ExponeaException("Flush mode is not manual.")
        }

        fun notAvailableForPlatform(name: String): ExponeaException {
            return ExponeaException("$name is not available for iOS platform.")
        }

        fun fetchError(description: String): ExponeaException {
            return ExponeaException("Data fetching failed: $description.")
        }

        fun common(description: String): ExponeaException {
            return ExponeaException("Error occurred: $description.")
        }
    }

    constructor(message: String) : super(message)
    constructor(message: String, cause: Throwable) : super(message, cause)
}
