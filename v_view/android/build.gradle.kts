allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.concurrent" && requested.name == "concurrent-futures") {
                useVersion("1.2.0")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    pluginManager.withPlugin("com.android.library") {
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures-ktx:1.2.0")
    }
    pluginManager.withPlugin("com.android.application") {
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        dependencies.add("implementation", "androidx.concurrent:concurrent-futures-ktx:1.2.0")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
