// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") version "8.2.1" apply false
    id("com.android.library") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// বিল্ড ডিরেক্টরি সেটআপ করার সময় একটু সাবধানে করতে হয় যাতে পাথ এরর না হয়
rootProject.layout.buildDirectory.value(layout.buildDirectory.dir("../build"))

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}