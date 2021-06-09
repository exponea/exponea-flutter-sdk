package com.exponea.exception

class ExponeaDataException : Exception {
    companion object {
        fun missingProperty(property: String): ExponeaDataException {
            return ExponeaDataException("Property $property is required.")
        }

        fun invalidType(property: String): ExponeaDataException {
            return ExponeaDataException("Invalid type for $property.")
        }

        fun invalidValue(property: String, value: String): ExponeaDataException {
            return ExponeaDataException("Invalid value $value for $property.")
        }
    }

    constructor(message: String) : super(message)
    constructor(message: String, cause: Throwable) : super(message, cause)
}
