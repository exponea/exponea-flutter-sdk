plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Each messaging plugin needs its own config file, so apply it only for its flavor
// (same approach as the legacy example and the Android example app).
val requestedTasks = gradle.startParameter.taskRequests.toString().lowercase()
if (requestedTasks.contains("gms")) {
    apply(plugin = "com.google.gms.google-services")
}
if (requestedTasks.contains("hms")) {
    apply(plugin = "com.huawei.agconnect")
}

android {
    namespace = "com.exponea.example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.exponea.sdk.example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("config") {
            // Shared demo key, so builds from every machine and CI can be installed over each other.
            // Caution! In production, you need to generate your own keystore file.
            storeFile = file("Exponea.jks")
            storePassword = "Exponea"
            keyPassword = "Exponea"
            keyAlias = "key0"
        }
    }

    flavorDimensions += "messagingService"
    productFlavors {
        create("gms") {
            dimension = "messagingService"
        }
        create("hms") {
            dimension = "messagingService"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("config")
        }
        release {
            signingConfig = signingConfigs.getByName("config")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Native SDK for the customer token provider; keep equal to the plugin's exponeaSdkVersion.
    implementation("com.exponea.sdk:sdk:5.3.1")

    // Same versions as the legacy example app.
    "gmsImplementation"("com.google.firebase:firebase-messaging:23.0.0")
    "hmsImplementation"("com.huawei.agconnect:agconnect-core:1.9.1.300")
    "hmsImplementation"("com.huawei.hms:push:6.11.0.300")

    // Plugin Kotlin unit tests (src/test) read fixtures from the repository test/values.
    testImplementation("junit:junit:4.12")
    testImplementation("com.google.code.gson:gson:2.10.1")
}
