Integrating a bash script (.sh) into a C++/Android SDK project and embedding it within an Android .apk can be a complex task. 
However, we can outline the steps and provide a general solution for embedding the script, making it executable on the Android platform.
We'll break this down into a few distinct steps:
Embedding the .sh script into a C++ Android project.
Compiling the C++/Android project with the script.
Packaging and running the bash script using the Perl interpreter on Android (via native commands).
Instructions for building and testing on Android.

Step 1: Embedding the .sh Script into the C++ Android Project

In Android projects, especially those using Android NDK (Native Development Kit) with C++, we typically interact with the system using native code. However, since we want to run a bash script (.sh), we need to embed it into the app and invoke it at runtime.
We'll store the script as a raw asset in the Android project so that it can be read and executed at runtime.

1.1 Create the Android Project and Add the .sh Script

Create an Android Project in Android Studio if you don’t already have one.
Create a assets directory in the src/main folder to store the .sh script.

Folder Structure:

```bash
app/
 ├── src/
 │    ├── main/
 │    │    ├── cpp/               # C++ code
 │    │    ├── assets/            # Store the .sh script here
 │    │    └── AndroidManifest.xml
 │    └── res/
 └── build.gradle
```

1.2 Modify CMakeLists.txt (NDK C++ Configuration)

In the CMakeLists.txt file, ensure you link the necessary libraries (like libc for system commands) to run system-level commands.

```bash
# CMakeLists.txt
cmake_minimum_required(VERSION 3.10.2)

project("your_project_name")

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)

# Add your source files here
add_library(native-lib
            SHARED
            src/main/cpp/native-lib.cpp)

# Link the necessary libraries (e.g., libc for system calls)
target_link_libraries(native-lib
                      log
                      android)
```

Step 2: Write C++ Code to Execute the .sh Script

We'll need to write a C++ function that can read the .sh script from the assets folder, save it to a temporary file, and then execute it using the Perl interpreter (or via shell commands).

2.1 Read the .sh Script from Assets

In native-lib.cpp:

```bash
#include <jni.h>
#include <string>
#include <android/log.h>
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

// Android log macro
#define LOG_TAG "NativeLib"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// Function to read file from assets
std::string readAssetFile(JNIEnv *env, jobject assetManager, const std::string &filename) {
    AAssetManager *mgr = AAssetManager_fromJava(env, assetManager);
    AAsset *asset = AAssetManager_open(mgr, filename.c_str(), AASSET_MODE_STREAMING);
    if (asset == nullptr) {
        LOGI("Asset not found: %s", filename.c_str());
        return "";
    }

    off_t assetLength = AAsset_getLength(asset);
    std::string content(assetLength, ' ');
    AAsset_read(asset, &content[0], assetLength);
    AAsset_close(asset);
    return content;
}

// Function to execute a shell command (Perl script execution)
void executeShellCommand(const std::string &command) {
    FILE *fp = popen(command.c_str(), "r");
    if (fp == nullptr) {
        LOGI("Error opening pipe for command: %s", command.c_str());
        return;
    }

    char buffer[128];
    while (fgets(buffer, sizeof(buffer), fp) != nullptr) {
        LOGI("%s", buffer);
    }

    fclose(fp);
}

// JNI function to run the bash script from assets
extern "C"
JNIEXPORT void JNICALL
Java_com_example_yourapp_MainActivity_runShellScript(JNIEnv *env, jobject thiz, jobject assetManager) {
    // Step 1: Read the .sh script from assets
    std::string scriptContent = readAssetFile(env, assetManager, "fujizksy.sh");

    // Step 2: Write the script content to a temporary file
    const char *tempFilePath = "/data/data/com.example.yourapp/files/fujizksy.sh";
    std::ofstream scriptFile(tempFilePath);
    scriptFile << scriptContent;
    scriptFile.close();

    // Step 3: Make the file executable
    std::string command = "chmod +x " + std::string(tempFilePath);
    executeShellCommand(command);

    // Step 4: Run the script using Perl (or bash)
    command = "perl " + std::string(tempFilePath);
    executeShellCommand(command);
}
```
Step 3: Modify the Java Code to Call the C++ Method

In the Java part of your Android project, you need to call the JNI function we just created to invoke the bash script.

3.1 Java Code to Call the Native Method

In MainActivity.java or your activity class:

 ```bash
package com.example.yourapp;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends Activity {

    // Load the native library
    static {
        System.loadLibrary("native-lib");
    }

    // Declare the native method
    public native void runShellScript(Object assetManager);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Set up button to trigger the script execution
        Button runButton = findViewById(R.id.runButton);
        runButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Run the shell script when the button is clicked
                runShellScript(getAssets());
            }
        });
    }
}
```

3.2 Create Layout for Button in activity_main.xml

```bash
<Button
    android:id="@+id/runButton"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Run Script"
    android:layout_centerInParent="true" />
```
📝 Notes:

Perl Interpreter: Ensure that the Perl interpreter is available on the Android device. This is usually possible if you have a rooted device or use Android NDK with the appropriate libraries.
Permissions: The script may require elevated privileges to run certain commands (especially those that deal with networking or system-level firewall settings).
Testing on Android: Some commands, like modifying firewall settings, may not be fully supported on unrooted devices.
Portability: You can modify the script for different environments (Android, Linux, FreeBSD, etc.) depending on the detected platform.
