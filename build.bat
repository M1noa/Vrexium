@echo off
setlocal enabledelayedexpansion

echo Vrexium Build Script (Windows)
echo ============================

:: Delete existing injector.jar if it exists
if exist injector.jar (
    echo Removing existing injector.jar...
    del injector.jar
)

:: Create lib directory if it doesn't exist
if not exist lib mkdir lib

:: Function to verify JAR file
setlocal enabledelayedexpansion
:verify_jar
set jar_file=%~1
if exist %jar_file% (
    jar tf %jar_file% >nul 2>&1
    if !errorlevel! equ 0 (
        echo Using existing %~nx1
        exit /b 0
    )
)
exit /b 1

:: Check and download dependencies
echo Checking dependencies...

:: Check and download Apache Commons IO
call :verify_jar "lib\commons-io.jar"
if !errorlevel! neq 0 (
    echo Downloading Apache Commons IO...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://downloads.apache.org/commons/io/binaries/commons-io-2.15.1-bin.zip', 'lib\commons-io.zip')"
    powershell Expand-Archive lib\commons-io.zip -DestinationPath lib\commons-io-temp
    move /Y lib\commons-io-temp\commons-io-*\commons-io-*.jar lib\commons-io.jar
    rd /S /Q lib\commons-io-temp
    del lib\commons-io.zip
)

:: Check and download ASM
call :verify_jar "lib\asm.jar"
if !errorlevel! neq 0 (
    echo Downloading ASM...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repository.ow2.org/nexus/content/repositories/releases/org/ow2/asm/asm/9.6/asm-9.6.jar', 'lib\asm.jar')"
)

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

:: Cleanup
echo Cleaning up build artifacts...
rd /S /Q lib
rd /S /Q build
rd /S /Q org

echo Build complete! Output: injector.jar
pause