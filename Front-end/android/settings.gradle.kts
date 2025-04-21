pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Front_end"

include(":app")

// Flutter module configuration
def flutterSdkPath = file('../flutter')
if (flutterSdkPath.exists()) {
    include(":flutter")
    project(":flutter").projectDir = flutterSdkPath
} else {
    include(":flutter")
    project(":flutter").projectDir = file('${System.getenv("FLUTTER_SDK")}/packages/flutter')
}