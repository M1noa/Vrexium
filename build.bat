@echo off
setlocal enabledelayedexpansion

echo Vrexium Build Script (Windows)
echo ============================

:: Create lib directory if it doesn't exist
if not exist lib mkdir lib

:: Download dependencies
echo Downloading dependencies...

:: Download Apache Commons IO
echo Downloading Apache Commons IO...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://downloads.apache.org/commons/io/binaries/commons-io-2.15.1-bin.zip', 'lib\commons-io.zip')"

:: Download ASM
echo Downloading ASM...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm/9.6/asm-9.6.jar', 'lib\asm.jar')"

:: Extract Apache Commons IO
echo Extracting Apache Commons IO...
powershell Expand-Archive lib\commons-io.zip -DestinationPath lib\commons-io-temp
move /Y lib\commons-io-temp\commons-io-*\commons-io-*.jar lib\commons-io.jar
rd /S /Q lib\commons-io-temp
del lib\commons-io.zip

:: Create build directory
if not exist build mkdir build

:: Compile the project
echo Compiling project...
javac -cp "lib\commons-io.jar;lib\asm.jar" -d build src\meow\minoa\vrexium\*.java src\meow\minoa\gui\*.java

:: Create JAR file
echo Creating JAR file...
jar cvfm injector.jar src\META-INF\MANIFEST.MF -C build .

echo Build complete! Output: injector.jar
pause