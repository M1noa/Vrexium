@echo off
setlocal enabledelayedexpansion

echo Vrexium Build Script (Windows)
echo ============================

:: Clean up previous build artifacts
echo Cleaning up previous builds...
del /F /Q injector.jar vrex_build.jar 2>nul

:: Create lib directory if it doesn't exist
if not exist lib mkdir lib

:: Download dependencies
echo Downloading dependencies...

:: Download Apache Commons IO
echo Downloading Apache Commons IO...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://downloads.apache.org/commons/io/binaries/commons-io-2.15.1-bin.zip', 'lib\commons-io.zip')"

:: Download ASM dependencies
echo Downloading ASM dependencies...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm/9.6/asm-9.6.jar', 'lib\asm.jar')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm-tree/9.6/asm-tree-9.6.jar', 'lib\asm-tree.jar')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm-commons/9.6/asm-commons-9.6.jar', 'lib\asm-commons.jar')"

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
javac -cp "lib\commons-io.jar;lib\asm.jar;lib\asm-tree.jar;lib\asm-commons.jar" -d build src\meow\minoa\vrexium\*.java src\meow\minoa\vrexium\utils\*.java src\meow\minoa\gui\*.java

:: Create injector JAR
echo Creating injector JAR...
cd build

:: Extract ASM dependencies
for %%f in (..\lib\asm*.jar) do (
    jar xf "%%f"
)

:: Create the injector JAR with ASM classes included
jar cvfm ..\injector.jar ..\src\META-INF\MANIFEST.MF meow\minoa\vrexium\Main*.class meow\minoa\vrexium\utils\Injector*.class meow\minoa\vrexium\utils\JarLoader*.class meow\minoa\vrexium\utils\Loader*.class meow\minoa\vrexium\utils\OptionsParser*.class meow\minoa\gui\VrexiumGUI*.class org\objectweb\asm\**\*.class
cd ..

:: Create Vrexium plugin JAR
echo Creating Vrexium plugin JAR...
cd build
jar cvf ..\vrex_build.jar meow\minoa\vrexium\SpigotAPI.class
cd ..

echo Build complete! Output: injector.jar and vrex_build.jar

:: Clean up downloaded dependencies and build artifacts
echo Cleaning up...
rd /S /Q lib
rd /S /Q build

pause