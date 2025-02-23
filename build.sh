#!/bin/bash

echo "Vrexium Build Script (Unix)"
echo "=========================="

# Delete existing injector.jar if it exists
if [ -f "injector.jar" ]; then
    echo "Removing existing injector.jar..."
    rm injector.jar
fi

# Create lib directory if it doesn't exist
mkdir -p lib

# Function to verify JAR file integrity
verify_jar() {
    local jar_file=$1
    if [ -f "$jar_file" ] && jar tf "$jar_file" > /dev/null 2>&1; then
        echo "Using existing $(basename $jar_file)"
        return 0
    fi
    return 1
}

# Function to download file with retry and validation
download_file() {
    local url=$1
    local output=$2
    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        echo "Downloading $(basename $output)... (Attempt $((retry_count + 1)))"
        if curl -L -f "$url" -o "$output" 2>/dev/null && [ -s "$output" ]; then
            # Verify JAR file integrity
            if jar tf "$output" > /dev/null 2>&1; then
                echo "Successfully downloaded $(basename $output)"
                return 0
            else
                echo "Error: Downloaded file is corrupted (invalid JAR format), retrying..."
                rm -f "$output"
            fi
        else
            echo "Error: Download failed (HTTP error or connection issue), retrying..."
            rm -f "$output"
        fi
        retry_count=$((retry_count + 1))
        sleep 2
    done
    return 1
}

# Check and download dependencies
echo "Checking dependencies..."

# Check and download Apache Commons IO
if ! verify_jar "lib/commons-io.jar"; then
    if ! download_file "https://repo1.maven.org/maven2/commons-io/commons-io/2.15.1/commons-io-2.15.1.jar" "lib/commons-io.jar"; then
        echo "Error: Failed to download Commons IO"
        exit 1
    fi
fi

# Check and download ASM
if ! verify_jar "lib/asm.jar"; then
    if ! download_file "https://repo1.maven.org/maven2/org/ow2/asm/asm/9.6/asm-9.6.jar" "lib/asm.jar"; then
        echo "Error: Failed to download ASM"
        exit 1
    fi
fi

# Check and download ASM Tree
if ! verify_jar "lib/asm-tree.jar"; then
    if ! download_file "https://repo1.maven.org/maven2/org/ow2/asm/asm-tree/9.6/asm-tree-9.6.jar" "lib/asm-tree.jar"; then
        echo "Error: Failed to download ASM Tree"
        exit 1
    fi
fi

# Check and download Spigot API
if ! verify_jar "lib/spigot-api.jar"; then
    if ! download_file "https://hub.spigotmc.org/nexus/repository/snapshots/org/spigotmc/spigot-api/1.20.4-R0.1-SNAPSHOT/spigot-api-1.20.4-R0.1-20240423.152506-123.jar" "lib/spigot-api.jar"; then
        echo "Error: Failed to download Spigot API. Please check your internet connection or try again later."
        echo "You can also manually download the Spigot API JAR and place it in the lib/ directory."
        exit 1
    fi
fi

# Create build directory
mkdir -p build

# Compile the project
echo "Compiling project..."
javac -cp "lib/commons-io.jar:lib/asm.jar:lib/asm-tree.jar:lib/spigot-api.jar" -d build src/meow/minoa/vrexium/*.java src/meow/minoa/gui/*.java src/meow/minoa/vrexium/utils/*.java

# Create JAR file
echo "Creating JAR file..."
# Create temp directory for dependencies
mkdir -p build/temp
# Extract dependency JARs
cd build/temp
for jar in ../../lib/*.jar; do
  jar xf "$jar"
done
cd ../..
# Create final JAR with dependencies
jar cvfm injector.jar src/META-INF/MANIFEST.MF -C build . -C build/temp .
# Clean up temp directory
rm -rf build/temp

# Cleanup
echo "Cleaning up build artifacts..."
rm -rf build/
rm -rf org/

echo "Build complete! Output: injector.jar"

# Make the script executable
chmod +x "$0"