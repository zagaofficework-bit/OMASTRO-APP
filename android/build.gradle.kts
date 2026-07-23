allprojects {
    repositories {
        google()
        mavenCentral()
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
    val configureProject = { proj: Project ->
        if (proj.hasProperty("android")) {
            proj.extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileSdkVersion(36)
            }
        }
    }
    if (state.executed) {
        configureProject(this)
    } else {
        afterEvaluate {
            configureProject(this)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
