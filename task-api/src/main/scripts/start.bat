@echo off
REM Script de démarrage de l'API Task pour Windows

setlocal

set APP_HOME=%~dp0..
set LIB_DIR=%APP_HOME%\lib
set CONFIG_DIR=%APP_HOME%\config
set LOG_DIR=%APP_HOME%\logs

REM Créer le répertoire de logs s'il n'existe pas
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Trouver le JAR
for %%f in ("%LIB_DIR%\task-api*.jar") do set JAR_FILE=%%f

if not defined JAR_FILE (
    echo Erreur: JAR non trouvé dans %LIB_DIR%
    exit /b 1
)

echo Démarrage de Task API...
echo JAR: %JAR_FILE%
echo Config: %CONFIG_DIR%

REM Démarrer l'application
start "Task API" java -jar "%JAR_FILE%" --spring.config.location="file:%CONFIG_DIR%/application.yml"

echo Task API démarrée.
echo Logs disponibles dans: %LOG_DIR%\task-api.log

endlocal

