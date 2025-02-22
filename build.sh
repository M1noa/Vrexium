#!/bin/bash

echo "Vrexium Build Script (Unix)"
echo "=========================="

# Create lib directory if it doesn't exist
mkdir -p lib

# Download dependencies
echo "Downloading dependencies..."

# Download Apache Commons IO
echo "Downloading Apache Commons IO..."
curl -L "https://repo1.maven.org/maven2/commons-io/commons-io/2.15.1/commons-io-2.15.1.jar" -o "lib/commons-io.jar"

# Download ASM
echo "Downloading ASM..."
curl -L "https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm/9.6/asm-9.6.jar" -o "lib/asm.jar"
curl -L "https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm-tree/9.6/asm-tree-9.6.jar" -o "lib/asm-tree.jar"

# Download ASM Commons
echo "Downloading ASM Commons..."
curl -L "https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm-commons/9.6/asm-commons-9.6.jar" -o "lib/asm-commons.jar"

# Download Spigot API
echo "Downloading Spigot API..."
curl -L "https://hub.spigotmc.org/nexus/content/repositories/snapshots/org/spigotmc/spigot-api/1.8.8-R0.1-SNAPSHOT/spigot-api-1.8.8-R0.1-20160221.082514-43.jar" -o "lib/spigot-api.jar"

# Create build directory
mkdir -p build

# Rename files to match class names
echo "Renaming files to match class names..."
mv src/meow/minoa/vrexium/main.java src/meow/minoa/vrexium/Main.java
mv src/meow/minoa/vrexium/spigotapi.java src/meow/minoa/vrexium/SpigotAPI.java
mv src/meow/minoa/vrexium/utils/injector.java src/meow/minoa/vrexium/utils/Injector.java
mv src/meow/minoa/vrexium/utils/optionsparser.java src/meow/minoa/vrexium/utils/OptionsParser.java
mv src/meow/minoa/gui/vrexiumgui.java src/meow/minoa/gui/VrexiumGUI.java

# Compile the project
echo "Compiling project..."
javac -cp "lib/commons-io.jar:lib/asm.jar:lib/asm-tree.jar:lib/asm-commons.jar:lib/spigot-api.jar" --add-exports java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED -d build src/meow/minoa/vrexium/*.java src/meow/minoa/vrexium/utils/*.java src/meow/minoa/gui/*.java

# Create injector JAR
echo "Creating injector JAR..."
cd build
jar cvfm ../injector.jar ../src/META-INF/MANIFEST.MF meow/minoa/vrexium/Main.class meow/minoa/vrexium/utils/Injector.class meow/minoa/vrexium/utils/JarLoader.class meow/minoa/vrexium/utils/Loader.class meow/minoa/vrexium/utils/OptionsParser.class meow/minoa/gui/VrexiumGUI.class
cd ..

# Create Vrexium plugin JAR
echo "Creating Vrexium plugin JAR..."
cd build
jar cvf ../vrex_build.jar meow/minoa/vrexium/SpigotAPI.class
cd ..

echo "Build complete! Output: injector.jar and vrex_build.jar"

# Clean up downloaded dependencies and build artifacts
echo "Cleaning up..."
rm -rf lib/
rm -rf build/

# Make the script executable
chmod +x "$0"