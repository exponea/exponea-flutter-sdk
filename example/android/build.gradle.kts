buildscript {
    repositories {
        google()
        mavenCentral()
        maven("https://developer.huawei.com/repo/")
    }
    dependencies {
        // Applied only to the `hms` flavor (see app/build.gradle.kts). agcp pulls an old AGP
        // (via agconnect-apms-plugin) that breaks the AGP 9 DSL, so keep the project's AGP.
        // agcp looks this declaration up; keep it equal to the AGP version in settings.gradle.kts.
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("com.huawei.agconnect:agcp:1.9.3.300") {
            exclude(group = "com.android.tools.build")
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://developer.huawei.com/repo/")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
