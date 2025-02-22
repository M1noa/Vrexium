#!/bin/bash

echo "Vrexium Build Script (Unix)"
echo "=========================="

# Create lib directory if it doesn't exist
mkdir -p lib

# Download dependencies
echo "Downloading dependencies..."

# Download Apache Commons IO
echo "Downloading Apache Commons IO..."
curl -L "https://downloads.apache.org/commons/io/binaries/commons-io-2.15.1-bin.zip" -o "lib/commons-io.zip"

# Download ASM
echo "Downloading ASM..."
curl -L "https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm/9.6/asm-9.6.jar" -o "lib/asm.jar"

# Extract Apache Commons IO
echo "Extracting Apache Commons IO..."
unzip -q "lib/commons-io.zip" -d "lib/commons-io-temp"
mv lib/commons-io-temp/commons-io-*/commons-io-*.jar lib/commons-io.jar
rm -rf lib/commons-io-temp
rm lib/commons-io.zip

# Create build directory
mkdir -p build

# Compile the project
echo "Compiling project..."
javac -cp "lib/commons-io.jar:lib/asm.jar" -d build src/meow/minoa/vrexium/*.java src/meow/minoa/gui/*.java

# Create JAR file
echo "Creating JAR file..."
jar cvfm injector.jar src/META-INF/MANIFEST.MF -C build .

echo "Build complete! Output: injector.jar"

# Make the script executable
chmod +x "$0"