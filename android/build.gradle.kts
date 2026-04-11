buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = java.net.URI.create("https://chaquo.com/maven") }
    }
    dependencies {
        // Aligned with settings.gradle.kts version
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("com.chaquo.python:gradle:16.0.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = java.net.URI.create("https://chaquo.com/maven") }
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

subprojects {
    val fixNamespace = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                val groupName = project.group.toString()
                android.namespace = if (groupName.isNotEmpty()) groupName else "com.finpath.finpath.${project.name.replace("-", ".")}"
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate {
            fixNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
