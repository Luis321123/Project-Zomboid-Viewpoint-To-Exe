@echo off
rem  Lanzador de Project Zomboid 42.21 (ZombieBuddy + Viewpoint) para Windows.
rem  Funciona tanto dentro de la carpeta del juego como en _actualizacion_b42.21.
setlocal
set "GD=%~dp0"
if not exist "%GD%\projectzomboid.jar" set "GD=%~dp0.."
cd /d "%GD%"
echo Arrancando Project Zomboid desde: %CD%
start "" "ProjectZomboid64.exe"
endlocal
