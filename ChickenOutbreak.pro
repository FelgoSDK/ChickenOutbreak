# allows to add DEPLOYMENTFOLDERS and links to the V-Play library and QtCreator auto-completion
CONFIG += v-play

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += \
#    resources_ChickenOutbreak.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the V-Play Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp


# Add Icon
#win32 {
#    # Icon Resource for exe file
#    RC_FILE += win/app_icon.rc
#    # Icon Resource for dynamic icon of title bar and task bar
#    # If using MSVC the code may end up in "release" or "debug" sub dir
#    CONFIG(debug, debug|release): OUTDIR = debug
#    else: OUTDIR = release
#    # copy the icon file to the exe folder
#    QMAKE_POST_LINK += copy /y \"$$PWD\"\\win\\app_icon.ico \"$$OUT_PWD\"\\\"$$OUTDIRs\"
#}

# Following configs are needed for Mac App Store publishing
#macx {
#    COMPANY = "V-Play GmbH"
#    BUNDLEID = net.vplay.demos.mac.ChickenOutbreak
#    ICON = macx/app_icon.icns
#    QMAKE_INFO_PLIST = macx/ChickenOutbreak-Info.plist
#    ENTITLEMENTS = macx/ChickenOutbreak.entitlements
#}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xm
    LIBS += -lFacebookPlugin
    LIBS += -lFlurryPlugin
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}
